## Load Packages
library(openxlsx)
library(reshape2)
library(jsonlite)
library(RCurl)

## Set Options
options(stringsAsFactors=FALSE)

## Set Working Directory
setwd("F:/Documents/Website/R Projects/Politics/2016 Election")

## Process Data
stateResults <- countyResults[countyResults$State %in% c("T","DC"), c("County",	# create simplifed state DF
				"Clinton",														#
				"Trump")] 							  							#

names(stateResults)[1] <- "State_ID"											# rename State column

stateResults$Clinton <- as.numeric(stateResults$Clinton)			  			# convert to numeric
stateResults$Trump <- as.numeric(stateResults$Trump)							#

stateResults <- stateResults[!is.na(stateResults$State_ID), ]					# remove NA rows
stateResults <- stateResults[complete.cases(stateResults), ]					#

stateResults <- merge(stateResults,												# Add
					  states,													# state
					  by.x = "State_ID",										# abbreviations
					  by.y = "State",											# 
					  all.x = TRUE)												#
	  
# Create Trump - Clinton spread
stateResults$Trump_State_Spread <- stateResults$Trump - stateResults$Clinton

## Merge County Results with Polling Average
state_poll_results <- merge(stateResults,
							Poll_Avg,
							by.x = "Abbreviation",
							by.y = "State_ID",
							all.x = TRUE)
									
state_poll_results <- unique(state_poll_results)

# Create Trump State Spread - Trump Polling Spread spread
state_poll_results$Trump_ResultPoll_Spread_State <- (state_poll_results$Trump_State_Spread * 100) - state_poll_results$Trump_Polling_Spread
state_poll_results$Trump_ResultPoll_Spread_State <- 
		replace(state_poll_results$Trump_ResultPoll_Spread_State,
				is.na(state_poll_results$Trump_ResultPoll_Spread_State),
				0)

## Create JSON df
#Trump
trump_state_spreads <- data.frame(value = state_poll_results$Trump_ResultPoll_Spread_State,
								  code = tolower(state_poll_results$Abbreviation),
								  Poll_Spread = state_poll_results$Trump_Polling_Spread,
								  Result_Spread = state_poll_results$Trump_State_Spread * 100,
								  stringsAsFactors = FALSE)
trump_state_spreads <- trump_state_spreads[trump_state_spreads$code != "dc",]
json_trump_states <- toJSON(trump_state_spreads)


## Upload JSON file to FTP
#Trump
write(json_trump_states, "json_trump_states.json")
ftpUpload("json_trump_states.json",
		paste0(ftp,"json_trump_states.json"),
		userpwd = cred)