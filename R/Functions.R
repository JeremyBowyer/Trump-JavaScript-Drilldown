## Stored functions to be used in Election Results Analysis

right <- function (string, char){
	substr(string,nchar(string)-(char-1),nchar(string))
}