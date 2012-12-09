## define the function read in the affymetrix microarray perform microarray QC 
## -----------------------------------------------------------------------------


## load the packages I nees in this step
library(affy)						# used for affymetrix microarray analyses
library(affyQCReport)				# used for obtain quality control measures
library(hgu133plus2cdf)				# used for cdf file


preprocess <- function(filename) {

	## Import experiment design information from targets.txt
	targets <- read.AnnotatedDataFrame(filename, header=TRUE, row.names = 1, as.is =TRUE)

	## Read in raw data (probe intensities for all arrays into memory)
	data <- ReadAffy(filenames = pData(targets)$FileName, phenoData = targets, 
		cdfname="hgu133plus2cdf")

	## mas5 normalization
	data.mas5 <- mas5(data)

	## Get expression levels
	mas5DataExp <-exprs(data.mas5)
	write.table(mas5DataExp, file = "mas5DataExp.txt", quote = FALSE, 
		row.names = TRUE, col.names = TRUE, sep = "\t")

	## perform the QC
	QCReport(data, file="QC_report.pdf")

}