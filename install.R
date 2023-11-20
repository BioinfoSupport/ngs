


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# CRAN packages
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

install_cran <- function() {
  # Development tools
  install.packages(c('Rcpp', 'devtools', 'rmarkdown'))
  install.packages(c('optparse', 'tidyverse'))
  
  # File formats
  install.packages(c('curl', 'XML', 'rjson', 'jsonlite', 'rhdf5'))
  
  # Graph
  install.packages(c('Matrix', 'igraph', 'tidygraph', 'ggraph'))
  
  # ggplot extensions
  install.packages(c('scales', 'ggforce', 'ggrepel', 'patchwork'))
  install.packages(c('RColorBrewer', 'wesanderson'))
  install.packages(c('jpeg', 'png'))
  
  # Shiny extensions
  install.packages(c('bs4Dash', 'reactlog'))
  
  # Dimension reduction
  install.packages(c('irlba', 'umap', 'Rtsne'))
}

install_ml <- function() {
  # Machine learning
  install.packages(c('torch', 'luz'));torch::install_torch()
}




#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Bioconductor packages
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

install_bioc <- function() {
  BiocManager::install(c('BiocParallel'))
  
  # Genomic
  BiocManager::install(c('ShortReads', 'Biostrings', 'Rsamtools', 'rtracklayer', 'GenomicRanges', 'GenomicFeatures', 'GenomicAlignments', 'SummarizedExperiment'))
  BiocManager::install(c('edgeR', 'DESeq2'))
  BiocManager::install(c('fgsea'))
  
  # HDF5 array
  BiocManager::install(c('HDF5Array'))
  
  # Single-cell tools
  BiocManager::install(c('SingleCellExperiment', 'DropletUtils', 'scuttle', 'scran', 'scater'))
}


