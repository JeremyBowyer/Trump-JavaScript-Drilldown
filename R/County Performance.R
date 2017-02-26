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
countyResults <- readWorkbook(electionResults, sheet = "County")
names(countyResults)[1:2] <- c("County", "State")
# Assign proper congressional county IDs
countyResults[countyResults$State == "NE" && countyResults$County == "Dixon", "CD"] <- 3
countyResults[countyResults$State == "NE" && countyResults$County == "Sarpy", "CD"] <- 2
countyResults[countyResults$State == "ME" && countyResults$County == "Kennebec", "CD"] <- 1

simpCounty <- countyResults[, c("County",
				"State",
				"CD",
				"Clinton",
				"Trump",
				"CTY")]   				  	  # create simple county results DF
simpCounty <- simpCounty[simpCounty$State != "T", ]			 	  # remove state totals
simpCounty <- simpCounty[!is.na(simpCounty$County), ]			 	  # remove missing data rows
simpCounty$Clinton <- as.numeric(simpCounty$Clinton)			 	  # convert to numeric
simpCounty$Trump <- as.numeric(simpCounty$Trump)			  	  #
simpCounty$CTY <- paste0("000",simpCounty$CTY)					  # pad CTY with extra 0s
simpCounty$CTY <- right(simpCounty$CTY, 3)					  # trim extra 0s, left with only 3 digits

simpCounty$County_ID <-							  	  #
		paste0("us-",tolower(simpCounty$State),"-",simpCounty$CTY)	  # create county ID
simpCounty$State_ID <- simpCounty$State

simpCounty[simpCounty$State_ID == "ME", "State_ID"] <- 			  	  # Replace Maine state id with state+cd
		paste0(simpCounty[simpCounty$State_ID == "ME", "State"], 	  #
				simpCounty[simpCounty$State_ID == "ME", "CD"])	  #
simpCounty$State_ID <- gsub("NA","",simpCounty$State_ID)		  	  # If no cd, just use state id

# Create Trump - Clinton Spread
simpCounty$Trump_County_Spread <- simpCounty$Trump - simpCounty$Clinton

## Merge County Results with Polling Average
polls_results <- merge(simpCounty[, c("County",
				      "Trump",
				      "Clinton",
				      "Trump_County_Spread",
				      "County_ID",
				      "State_ID")],
			Poll_Avg,
			by = "State_ID",
			all.x = TRUE)
polls_results <- unique(polls_results)

## Create Spreads
# Trump
polls_results$Trump_Spread <- (polls_results$Trump_County_Spread * 100) - polls_results$Trump_Polling_Spread
polls_results$Trump_Spread <- replace(polls_results$Trump_Spread, is.na(polls_results$Trump_Spread), 0)


## Create JSON df
#Trump
county_trump_spreads <- data.frame(code = polls_results$County_ID,
				   name = polls_results$County,
				   Poll_Spread = polls_results$Trump_Polling_Spread,
				   Result_Spread = polls_results$Trump_County_Spread * 100,
				   value = polls_results$Trump_Spread, stringsAsFactors = FALSE)
