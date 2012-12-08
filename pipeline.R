## this is the whole pipeline for microarray
## function were called and all the elements could be 

## 1. call the function I defined long time ago, these function download the microarray and perform analysis
## ---------------------------------------------------------------------------------------------------------

source(file = "/Users/bioinfor/github/testrepo/celdownload.R")

## 2. the main body of the R script
## -----------------------------------

args <- commandArgs()
filename <- args[6]
GEO <- sub('.txt', '', filename)
celdownload(GEO)