ARG BASE_IMAGE=bioconductor/bioconductor_docker:3.18

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# K8
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM ${BASE_IMAGE} as k8

# Install k8 and paftools.js from minimap2
RUN curl -kL https://nodejs.org/dist/v18.17.0/node-v18.17.0.tar.gz \
   | tar -C /tmp -zxf - && ln -s /tmp/node-v18.17.0 /tmp/nodejs 
RUN cd /tmp/nodejs && ./configure && make -j6
RUN git -C /tmp/nodejs/ clone https://github.com/attractivechaos/k8 && cd /tmp/nodejs/k8 && make CXX="g++ --static"





#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Main app
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM ${BASE_IMAGE}

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
      stringtie \
      ncbi-blast+ \
      bowtie \
      bowtie2 \
      python-htseq \
      fastqc \
      cutadapt \
      subread \
      salmon \
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
			officer \
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


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# paftools.js
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
COPY --from=k8 /tmp/nodejs/k8/k8 /usr/bin/
RUN curl -kL 'https://raw.githubusercontent.com/lh3/minimap2/master/misc/paftools.js' > /usr/bin/paftools.js \
  && chmod a+x /usr/bin/paftools.js

# Set default rstudio preferences
ADD rstudio-prefs.json /etc/rstudio/

# Define default mount points
VOLUME /home/rstudio/workdir
WORKDIR /home/rstudio/workdir

