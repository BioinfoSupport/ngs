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
			torch luz \
			shinyjs bs4Dash sortable shinycssloaders reactlog shinyWidgets \
    && rm -rf /tmp/downloaded_packages


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Install R packages from Bioconductor
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

ADD install_bioc.r /usr/local/bin/
RUN install_bioc.r --error --skipinstalled --ncpus -1 \
			BiocParallel ShortRead Biostrings Rsamtools rtracklayer GenomicRanges \
			GenomicFeatures GenomicAlignments SummarizedExperiment \
			edgeR DESeq2 \
			fgsea \
		  HDF5Array SingleCellExperiment DropletUtils scuttle scran scater \
			flowCore flowWorkspace CytoML FlowSOM \
    && rm -rf /tmp/downloaded_packages

# Set default preferences
ADD rstudio-prefs.json /etc/rstudio/

# Define default mount points
VOLUME /home/rstudio/workdir
WORKDIR /home/rstudio/workdir

