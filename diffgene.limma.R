## define the function to analyze the microarray with mas5 & limma
## -----------------------------------------------------------------------------


## explore the biological function of the genes
## source(file = "/Users/bioinfor/github/testrepo/biofun.R")
## plot the biological graph			
source(file = "/Users/bioinfor/github/testrepo/bioplot.R")


## load the packages I nees in this step
library(limma)						# used for differential gene detection
library(affy)						# used for affymetrix microarray analyses
library(hgu133plus2cdf)				# used for cdf file
library(hgu133plus2hsentrezgcdf)	# used for probe filtering
library(org.Hs.eg.db)				# used for transfer entrez gene ids to gene symbols and chromosome 
library(hgu133plus2.db)				# used for probe annotation


diffgene.limma <- function(filename) {

	## read in the affmetrix microarray data
	##--------------------------------------------

	## Import experiment design information from targets.txt
	targets <- read.AnnotatedDataFrame(filename, header=TRUE), row.names = "Name", as.is =TRUE)

	## Read in raw data (probe intensities for all arrays into memory)
	data <- ReadAffy(filenames = pData(targets)$FileName, phenoData = targets, 
		cdfname="hgu133plus2hsentrezgcdf")

	## mas5 normalization
	data.mas5 <- mas5(data)

	## Get expression levels
	mas5DataExp <-exprs(data.mas5)
	write.table(mas5DataExp, file = "mas5DataExp.txt", quote = FALSE, sep = "\t")

	
	## Absent/Present calls for the set of arrays
	##--------------------------------------------

	## format the entrez gene id, just delete the "_at" tail. :-)
	row.names(mas5DataExp) <- sub("(_at)", "", row.names(mas5DataExp))

	## Of course, it usually makes sense, not to consider genes that are not detectable/expressed. 
	mas5data <- mas5calls(data)
	## Get expression levels
	mas5PMA <-exprs(mas5data)

	## Merge A/P calls and filter all "A" probesets
	mas5calls.merged <- apply(mas5PMA, 1, paste, collapse="")
	Absent <- mas5DataExp[mas5calls.merged=="AAAA",]
	dim(Absent)[1]

	DataExp <- mas5DataExp[mas5calls.merged!="AAAA",]
	dim(DataExp)[1]


	## Compare the samples in the experiment
	##------------------------------------------


	## we don't want to analyze probes begin with "AFFY", so just remove them.
	entrezid <- row.names(DataExp)
	sel <- grep("^A", entrezid, perl=T, value=FALSE) # begin with AFFY, because entrez id is number
	DataExp <- DataExp[-sel,]

	## set up a design matrix
	condition <- targets$Condition
	design <- model.matrix(~0+factor(condition))
	colnames(design) <- c("C","T")

	## perform the linear model fit using the design matrix
	DataExp <- log2(DataExp)
	fit <- lmFit(DataExp, design)    
	names(fit)

	## set up a contrast.matrix which defines the comparisons that we want to investigate.
	contrast.matrix <- makeContrasts(T-C, levels=design)

	## let's calculate the differential expression summary statistics including log fold changes and p-values
	fit2 <- contrasts.fit(fit, contrast.matrix)
	ebayes <- eBayes(fit2)

	## how many differentially expressed genes (actually probes) we find?
	## Using a 0.05 FDR and 2 fold-change as cutoff
	t <- topTable(ebayes, number=nrow(DataExp), p.value=0.05, lfc=2)


	## Get the gene symbol that are mapped to an entrez gene identifiers
	x <- org.Hs.egSYMBOL
	mapped_genes <- mappedkeys(x)
	## Convert to a list
	xx <- x[mapped_genes]
	xx <- as.data.frame(x[mapped_genes])
	colnames(xx) <- c("ID", "symbol") 

	## Here is the table of differentially expressed gene
	diffgene <- merge(t, xx, by = "ID", all = FALSE)

	## save the result
	write(diffgene, "diff_gene.txt", quote = FALSE, sep = "\t", row.names = TRUE,
            col.names = TRUE,)

}