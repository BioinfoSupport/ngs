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
      jellyfish \
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

# pilon, unicycler, flye, spades, medaka


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Install R packages from CRAN
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
RUN install2.r --error --skipinstalled --ncpus -1 \
	    Rcpp devtools rmarkdown optparse testthat usethis tidyverse \
	    curl XML rjson jsonlite \
	    Matrix igraph tidygraph ggraph \
			scales ggforce ggrepel patchwork \
			RColorBrewer wesanderson \
			jpeg png \
			bs4Dash reactlog \
			irlba umap Rtsne \
			randomForest e1071 \
    && rm -rf /tmp/downloaded_packages
#install.packages(c('torch', 'luz'));torch::install_torch()


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Install R packages from Bioconductor
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
RUN R --no-save --no-restore <<EOF
	bioc_install <- function(pkgs,Ncpus=4L,...) {
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

