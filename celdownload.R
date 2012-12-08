## define the function downloading the raw data from Gene Expression Omnibus (GEO)
## --------------------------------------------------------------------------------

## load the packages I need in this step
library(GEOquery)   # used for download rawdata from GEO

celdownload <- function(GEO) {

    ## Specify which experiment to work with
    currpath <- getwd()

    ## download the rawdata
    rawfiles <- getGEOSuppFiles(GEO)

    ## unpack tar.gz file
    tarfile <- grep("\\.tar$", rownames(rawfiles), value = TRUE)
    untar(tarfile, exdir=GEO)
    celgzFiles <- unlist(list.files(GEO, pattern = "\\.CEL.gz", full.names = TRUE))

    ## gunzip all the gz files and we got the cel files for the further analysis
    for (i in 1:length(celgzFiles)) {
        gunzip(celgzFiles[i])
    }
    celFiles <- unlist(list.files(GEO, pattern = "\\.CEL", full.names = TRUE))

    ## delete the files i don't need anymore
    rarfiles <- unlist(list.files(GEO, pattern = "\\_RAW.tar", full.names = TRUE))
    chpfiles <- unlist(list.files(GEO, pattern = "\\.CHP.gz", full.names = TRUE))
    txtfiles <- unlist(list.files(GEO, pattern = "\\.txt", full.names = TRUE))
    x <- c(rarfiles, chpfiles, txtfiles)
    unlink(x, recursive = FALSE, force = FALSE)

}
