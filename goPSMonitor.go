package main

import (
	"encoding/json"
	"io/ioutil"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"

	"github.com/influxdata/influxdb/client/v2"
	"github.com/kardianos/service"
)

type Script struct {
	ScriptName   string `json:"name"`
	TimeInterval string `json:"interval"`
}

type fileConfig struct {
	Server   string `json:"server"`
	Port     string `json:"port"`
	Database string `json:"DB"`
	Scripts  []struct {
		ScriptName   string `json:"name"`
		TimeInterval string `json:"interval"`
	} `json:"scripts"`
}

var config fileConfig
var bp client.BatchPoints
var cl *client.Client
var errCount int

var logger service.Logger
var path string

type program struct{}

func (p *program) Start(s service.Service) error {
	// Start should not block. Do the actual work async.
	go p.run()
	return nil
}

func (p *program) run() {

	for _, sc := range config.Scripts {

		go func(sc Script) {

			for {
				scriptOutput(sc.ScriptName, sc.TimeInterval)
			}
		}(sc)

	}
	quit := make(chan bool, 1)
	<-quit
}

func (p *program) Stop(s service.Service) error {
	// Stop should not block. Return with a few seconds.
	return nil
}

func main() {
	svcConfig := &service.Config{
		Name:        "ilionMonitor",
		DisplayName: "ilionMonitor",
		Description: "This is an example Go service.",
	}

	prg := &program{}
	s, err := service.New(prg, svcConfig)
	checkError(err)
	initProcess()
	logger, err = s.Logger(nil)
	checkError(err)
	err = s.Run()
	checkError(err)
}

func initProcess() {
	//Read configFile
	path = os.Getenv("GOPSMONPATH")

	config = readJSONConfigFile()
	//Instantiate clientHTTP
	c, err := client.NewHTTPClient(client.HTTPConfig{
		Addr: config.Server + ":" + config.Port,
	})
	cl = &c

	checkError(err)

}

func checkError(e error) {

	if e != nil {
		if errCount < 5 {
			errCount++
			delay("5min")
		} else {
			f, _ := os.Create(path + "\\errorFile")
			defer f.Close()
			t := time.Now().Format("2006-01-02 15:04:05")
			errorString := t + "  " + e.Error()

			error := []byte(errorString)
			f.Write(error)
			panic(e)
		}
	}
}

func readJSONConfigFile() fileConfig {

	file, err := ioutil.ReadFile(path + "\\config.json")
	checkError(err)

	var fileRead fileConfig

	json.Unmarshal(file, &fileRead)

	return fileRead
}

func scriptOutput(scriptName string, timeInterval string) {

	//<-delay(timeInterval).C
	delay(timeInterval)
	result, err := exec.Command("powershell", path+"\\"+scriptName).Output()
	checkError(err)
	writeData(result)

}

func delay(t string) {

	if strings.Contains(t, "min") {

		n, err := strconv.Atoi(strings.TrimRight(t, "min"))
		checkError(err)
		time.Sleep(time.Duration(n) * time.Minute)

	} else if strings.Contains(t, "sec") {

		n, err := strconv.Atoi(strings.TrimRight(t, "sec"))
		checkError(err)
		time.Sleep(time.Duration(n) * time.Second)
	}

}

func writeData(data []byte) {

	bpPoints := obtainDataPoints(strings.Split(string(data), "\n"))

	c := *cl
	// Write the batch
	err := c.Write(bpPoints)
	checkError(err)

}

func obtainDataPoints(s []string) client.BatchPoints {

	//Prepare batchPoint group
	bp, err := client.NewBatchPoints(client.BatchPointsConfig{
		Database:  config.Database,
		Precision: "s",
	})
	checkError(err)

	for _, line := range s {
		finalValues := map[string]interface{}{}
		finalTags := map[string]string{}
		var measurement string
		if line != "" {
			splitLine := strings.Split(line, " ")
			value := strings.Split(splitLine[1], ",")

			if len(value) == 1 {
				splitValue := strings.Split(value[0], "=")
				realValue := isNumber(splitValue[1])
				finalValues[splitValue[0]] = realValue

			} else {

				for _, val := range value {
					splitValue := strings.Split(val, "=")
					realValue := isNumber(splitValue[1])
					finalValues[splitValue[0]] = realValue
				}
			}

			tags := strings.Split(splitLine[0], ",")
			for index, t := range tags {
				if index == 0 {
					measurement = t
				} else {
					tag := strings.Split(t, "=")
					finalTags[tag[0]] = tag[1]
				}
			}

			pt, err := client.NewPoint(measurement, finalTags, finalValues, time.Now())
			checkError(err)
			bp.AddPoint(pt)

		}
	}

	return bp
}

func isNumber(s string) interface{} {
	noSpaces := strings.TrimSpace(s)

	i, err := strconv.Atoi(noSpaces)

	if err != nil {
		f, errI := strconv.ParseFloat(noSpaces, 32)
		if errI != nil {
			return noSpaces
		}
		return f
	}

	return i
}
