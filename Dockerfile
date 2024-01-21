# take this image to create a non-cuda environment
#FROM rocker/r-ver:4.3.1
FROM bioconductor/bioconductor_docker:3.18

# Install packages dependencies
RUN apt-get update && apt-get install -y \
      libz-dev \
      liblzma-dev \
      libbz2-dev \
      bzip2 \
      pigz \
      curl \
      git \
      make \
      seqtk \
      fastp \
      samtools \
      tabix \
      bcftools \
      bwa \
      minimap2 \
      kmc \
      libkmc-dev \
      bcalm \
      rna-star \
      hisat2 \
      ncbi-blast+ \
      bowtie \
      bowtie2 \
			python-htseq \
			fastqc \
			cutadapt \
			subread \      
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/*;




#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Install R packages from CRAN
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
RUN R --no-save --no-restore <<EOF
	install.packages <- function(pkgs,...) {
		utils::install.packages(pkgs,...)
		ipkgs <- rownames(installed.packages())
		stopifnot(all(pkgs %in% ipkgs))
	}
	
	# Development tools
	install.packages(c('Rcpp', 'devtools', 'rmarkdown', 'optparse', 'testthat', 'usethis'))
	install.packages(c('tidyverse'))
	
	# File formats
	install.packages(c('curl', 'XML', 'rjson', 'jsonlite'))
	
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
	
	# Machine learning
	install.packages(c('randomForest', 'e1071'))
	install.packages(c('torch', 'luz'));torch::install_torch()
EOF


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Install R packages from Bioconductor
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
RUN R --no-save --no-restore <<EOF
	bioc_install <- function(pkgs,...) {
		BiocManager::install(pkgs,...)
		ipkgs <- rownames(installed.packages())
		stopifnot(all(pkgs %in% ipkgs))
	}
  
  # Genomic
	bioc_install(c('BiocParallel','ShortRead', 'Biostrings', 'Rsamtools', 'rtracklayer', 'GenomicRanges', 'GenomicFeatures', 'GenomicAlignments', 'SummarizedExperiment'))
	bioc_install(c('edgeR', 'DESeq2'))
	bioc_install('fgsea')
  
  # Single-cell
	bioc_install(c('HDF5Array','SingleCellExperiment', 'DropletUtils', 'scuttle', 'scran', 'scater'))
	
	# Flow cytometry
	bioc_install(c('flowCore','flowWorkspace','CytoML','FlowSOM'))
EOF


# Define default mount points
VOLUME /home/rstudio/workdir
WORKDIR /home/rstudio/workdir

