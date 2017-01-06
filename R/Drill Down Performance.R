## Load Packages
library(openxlsx)
library(reshape2)
library(jsonlite)
library(RCurl)

## Set Options
options(stringsAsFactors=FALSE)

## Set Working Directory
setwd("F:/Documents/Website/R Projects/Politics/2016 Election")

# Set User/PW
cred <- "*********"

# Set FTP address
ftp <- "*********"

## Source requisite scripts
source("./Scripts/Load and Process Data.R")
source("./Scripts/County Performance.R")
source("./Scripts/State Performance.R")

## Process Data
#Trump
trump_drilldown_states <- trump_state_spreads
trump_drilldown_states$code <- paste0("us-",trump_drilldown_states$code)
trump_drilldown_counties <- county_trump_spreads[, c("code", "value","Poll_Spread","Result_Spread")]

## Create JSON files
#Trump
json_trump_drilldown_states <- toJSON(trump_drilldown_states)
json_trump_drilldown_counties <- toJSON(trump_drilldown_counties)


## Upload JSON file to FTP
#Trump
write(json_trump_drilldown_states, "json_trump_drilldown_states.json")			# STATES
ftpUpload("json_trump_drilldown_states.json",									#
		paste0(ftp,"json_trump_drilldown_states.json"),							#
		userpwd = cred)															#

write(json_trump_drilldown_counties, "json_trump_drilldown_counties.json")		# counties
ftpUpload("json_trump_drilldown_counties.json",									#
		paste0(ftp,"json_trump_drilldown_counties.json"),   					#
		userpwd = cred)															#
