## Load Packages
library(openxlsx)
library(reshape2)
library(jsonlite)
library(RCurl)

## Set Options
options(stringsAsFactors=FALSE)

## Set Working Directory
setwd("F:/Documents/Website/R Projects/Politics/2016 Election")

## Source Functions.R
source("./Scripts/Functions.R")

## Load State Abbreviations
states <- read.csv("./Files/Misc Files/State Abbreviations.csv", stringsAsFactors = FALSE)

#### County Election Results ####
## Load Data
electionResults <- loadWorkbook("./Files/County Results/Pres_Election_Data_2016n.xlsx")

#### State Polls ####
## Load Data
pollsDF <- read.csv("./Files/Polls -- 538/presidential_polls.csv")

## Process Poll Data
polls <- pollsDF[, c("type",														 #
					 "pollster",													 #
					 "state",														 #
					 "population",													 # create simple polls DF
					 "enddate",														 #
					 "poll_wt",														 #
					 "rawpoll_clinton",												 #
					 "rawpoll_trump")]											 	 #
	 
polls <- polls[polls$type == "polls-only", ]										 # only include polls-only polls, to avoid duplicates
polls <- polls[polls$population == "lv", ]											 # only include likely voter polls
polls <- polls[polls$state != "U.S.", ]												 # remove national polls
polls$enddate <- as.Date(polls$enddate, format = "%m/%d/%Y")			 			 # convert enddate to date
polls <- polls[order(polls$state, polls$enddate, decreasing = TRUE), ]				 # sort for simplicity
polls <- merge(polls, states, by.x = "state", by.y = "State", all.x = TRUE)			 # Add state abbreviations
polls$State_ID <- polls$Abbreviation
polls[polls$state == "Maine CD-1", "State_ID"] <- "ME1"
polls[polls$state == "Maine CD-2", "State_ID"] <- "ME2"

## Create 538-like weighted average

## Trump
trump_wtd_538 <- 
		unlist(as.list(by(polls, polls$State_ID, function(x) {
			sum(x$poll_wt * x$rawpoll_trump, na.rm = TRUE) / sum(x$poll_wt, na.rm = TRUE)
		})))

trump_df <- data.frame(State_ID = names(trump_wtd_538),
					   Trump_Polling_Average = trump_wtd_538)
			   
			   
## Clinton
clinton_wtd_538 <- 
	   unlist(as.list(by(polls, polls$State_ID, function(x) {
			sum(x$poll_wt * x$rawpoll_clinton, na.rm = TRUE) / sum(x$poll_wt, na.rm = TRUE)
	   })))
   
clinton_df <- data.frame(State_ID = names(clinton_wtd_538),
		   				 Clinton_Polling_Average = clinton_wtd_538)				 
				 
## Merge Polling Averages
Poll_Avg <- merge(trump_df, clinton_df, by = "State_ID")

## Create Trump Poll Spread
Poll_Avg$Trump_Polling_Spread <- Poll_Avg$Trump_Polling_Average - Poll_Avg$Clinton_Polling_Average
			