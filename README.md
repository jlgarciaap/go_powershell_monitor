# Golang Powershell Monitor for InfluxDb

This tool is for metrics capture in Windows systems with powershell scripts, and send them periodicaly to database InfluxDB.

On init, this tool read the file **config.json** where we need to write the databaseURL, databasePort, NewDatabaseName and scripts name with execute period.

This tool manage errors and test again every 5 minutes up to 25 minutes when this tool write a file with the error and stop working.

We have the possiblity to set this tool how a windows service.

### Required

We need to config a environment variable with name GOPSMONPATH and the value is the path where scripts are. 
