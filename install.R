


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# CRAN packages
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
install.packages.and.check <- function(pkgs,...,install.fun=install.packages) {
	install.fun(pkgs,...)
	ipkgs <- rownames(installed.packages())
	if (!all(pkgs %in% ipkgs)) {
		print("ERROR: not all packages installed...")
		print(paste("INSTALLED:",paste(intersect(pkgs,ipkgs),collapse=",")))
		print(paste("MISSING:",paste(setdiff(pkgs,ipkgs),collapse=",")))
		stop()
	}
}


install_cran <- function() {
  # Development tools
	install.packages.and.check(c('Rcpp', 'devtools', 'rmarkdown', 'optparse', 'testthat', 'usethis'))
	install.packages.and.check(c('tidyverse'))
  
  # File formats
	install.packages.and.check(c('curl', 'XML', 'rjson', 'jsonlite'))
  
  # Graph
	install.packages.and.check(c('Matrix', 'igraph', 'tidygraph', 'ggraph'))
  
  # ggplot extensions
	install.packages.and.check(c('scales', 'ggforce', 'ggrepel', 'patchwork'))
	install.packages.and.check(c('RColorBrewer', 'wesanderson'))
	install.packages.and.check(c('jpeg', 'png'))
  
  # Shiny extensions
	install.packages.and.check(c('bs4Dash', 'reactlog'))
  
  # Dimension reduction
	install.packages.and.check(c('irlba', 'umap', 'Rtsne'))
}

install_ml <- function() {
  # Machine learning
	install.packages.and.check(c('torch', 'luz'));torch::install_torch()
}




#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Bioconductor packages
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

install_bioc <- function() {
	install.packages.and.check(c('BiocParallel'),install.fun=BiocManager::install)
  
  # Genomic
	install.packages.and.check(c('ShortRead', 'Biostrings', 'Rsamtools', 'rtracklayer', 'GenomicRanges', 'GenomicFeatures', 'GenomicAlignments', 'SummarizedExperiment'),install.fun=BiocManager::install)
	install.packages.and.check(c('edgeR', 'DESeq2'),install.fun=BiocManager::install)
	install.packages.and.check(c('fgsea'),install.fun=BiocManager::install)
  
  # HDF5 array
	install.packages.and.check(c('HDF5Array'),install.fun=BiocManager::install)
  
  # Single-cell tools
	install.packages.and.check(c('SingleCellExperiment', 'DropletUtils', 'scuttle', 'scran', 'scater'),install.fun=BiocManager::install)
}


