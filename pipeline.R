## First pipeline for Affymetrix microarray with mas5 & limma
## Author: Xiaoqin Yang
## Data: 14:50, Dec 9, 2012 
##------------------------------------------------------------


## 1. call the function I defined long time ago
## 
## these function download the microarray and 
## perform analysis. FYI, the name of the function 
## is just the name of the Rscipts. 
## And the combination of the different source scripts 
## could facilitate various tasks of microarray analysis.
## -----------------------------------------------------


## microarray download
source(file = "/Users/bioinfor/github/testrepo/celdownload.R")
## remove the original txt file into the GSE folder		
source(file = "/Users/bioinfor/github/testrepo/my.file.rename.R")	 
## normalization & QC
source(file = "/Users/bioinfor/github/testrepo/preprocess.R")		
## differentially expressed gene detection
source(file = "/Users/bioinfor/github/testrepo/diffgene.limma.R")				


## 2. the main body of the R script
## -----------------------------------


## establish the folder and put the microarray files downloaded from GEO
args <- commandArgs()
filename <- args[6]
GEO <- sub('.txt', '', filename)
celdownload(GEO)


## remove the target file (txt format) into the folder just established
currpath <- getwd()
workpath <- paste(currpath, '/', GEO, sep="")
from <- paste(currpath, '/', filename, sep="")
to   <- paste(currpath, '/', GEO, '/', filename, sep="")
my.file.rename(from, to)
setwd(workpath)


## preprocess the microarray data using mas5 normalization method 
## and perform the QC analysis.
preprocess(filename)


## Analysis the microarray with limma package
diffgene.limma(filename)