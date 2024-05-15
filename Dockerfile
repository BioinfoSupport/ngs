FROM bioconductor/bioconductor_docker:3.19 as base

# Install packages dependencies
RUN apt-get update && apt-get install -y \
      libz-dev \
      liblzma-dev \
      libbz2-dev \
      libnetcdf-dev \
      bzip2 \
      pigz \
      curl \
      git \
      make \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/*;




#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# samtools
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM base as samtools
RUN mkdir -p /app \
   && curl -kL https://github.com/samtools/samtools/releases/download/1.19.2/samtools-1.19.2.tar.bz2 \
   | tar -C /app --strip-components=1 -jxf -
RUN cd /app && ./configure && make -j4

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# bcftools
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM base as bcftools
RUN mkdir -p /app \
   && curl -kL https://github.com/samtools/bcftools/releases/download/1.19/bcftools-1.19.tar.bz2 \
   | tar -C /app --strip-components=1 -jxf -
RUN cd /app && ./configure && make -j4

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# htslib
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM base as htslib
RUN mkdir -p /app \
   && curl -kL https://github.com/samtools/htslib/releases/download/1.19.1/htslib-1.19.1.tar.bz2 \
   | tar -C /app --strip-components=1 -jxf -
RUN cd /app && ./configure && make -j4 \
  && sed -e 's#@-includedir@#/usr/include#g;s#@-libdir@#/usr/lib#g;s#@-PACKAGE_VERSION@#1.19.1#g' htslib.pc.tmp > htslib.pc


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# K8 (needed for minimpa2/paftools.js)
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
#FROM base as k8
#RUN mkdir -p /app \
#   && curl -kL https://nodejs.org/dist/v18.17.0/node-v18.17.0.tar.gz \
#   | tar -C /app --strip-components=1 -zxf -
## WARNING: We have an issue here when compiling openssl on amd64, there an illegal instruction is raised
#RUN cd /app && ./configure --without-ssl && make -j6
#RUN git -C /app clone https://github.com/attractivechaos/k8 \
#   && cd /app/k8 && make CXX="g++ --static"

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# minimap2
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM base as minimap2
RUN mkdir -p /app \
   && curl -kL https://github.com/lh3/minimap2/releases/download/v2.27/minimap2-2.27.tar.bz2 \
   | tar -C /app --strip-components=1 -jxf -
RUN cd /app \
  && (if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
      make arm_neon=1 aarch64=1; \
  elif [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
      make; \
  fi)




#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# Main app
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
FROM base as main

RUN apt-get update && apt-get install -y \
      seqtk \
      fastp \
      bwa \
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
      rsem \
&& rm -rf /var/cache/apt/* /var/lib/apt/lists/*;
# pilon, unicycler, flye, spades, medaka



# Install R packages from CRAN
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


# Install R packages from Bioconductor
ADD install_bioc.r /usr/local/bin/
RUN install_bioc.r --error --skipinstalled --ncpus -1 \
			BiocParallel ShortRead Biostrings Rsamtools rtracklayer GenomicRanges \
			GenomicFeatures GenomicAlignments SummarizedExperiment \
			edgeR DESeq2 \
			fgsea \
		  HDF5Array SingleCellExperiment DropletUtils scuttle scran scater \
    && rm -rf /tmp/downloaded_packages


# Flow cytometry packages
#RUN install_bioc.r --error --skipinstalled --ncpus -1 \
#      flowCore flowWorkspace CytoML FlowSOM \
#    && rm -rf /tmp/downloaded_packages




# Install NCBI CLI
RUN curl -o /usr/bin/datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-$TARGETARCH/datasets' \
  && curl -o /usr/bin/dataformat 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-$TARGETARCH/dataformat' \
  && chmod a+x /usr/bin/datasets /usr/bin/dataformat



# minimap + (k8/paftools.js)
#COPY --from=k8 /app/k8/k8 /usr/local/bin/
COPY --from=minimap2 /app/minimap2 /app/misc/paftools.js /usr/local/bin/

# samtools 
COPY --from=samtools \
  /app/samtools \
  /app/misc/ace2sam \
  /app/misc/maq2sam-long \
  /app/misc/maq2sam-short \
  /app/misc/md5fa \
  /app/misc/md5sum-lite \
  /app/misc/wgsim \
  /app/misc/plot-* \
  /app/misc/*.pl \
  /usr/bin/
  
# bcftools
COPY --from=bcftools \
  /app/bcftools \
  /app/misc/*.py \
  /app/misc/run-roh.pl \
  /app/misc/vcfutils.pl \
  /usr/bin/
COPY --from=bcftools /app/plugins/*.so /usr/local/libexec/bcftools/

# htslib
COPY --from=htslib /app/annot-tsv /app/bgzip /app/htsfile /app/tabix /usr/bin
COPY --from=htslib /app/htslib/*.h /usr/include/htslib/
COPY --from=htslib /app/libhts.so /usr/lib/libhts.so.1.19.1
COPY --from=htslib /app/libhts.a /usr/lib/
COPY --from=htslib /app/htslib.pc /usr/lib/pkgconfig/
RUN ln -sf libhts.so.1.19.1 /usr/lib/libhts.so \
 && ln -sf libhts.so.1.19.1 /usr/lib/libhts.so.3






# Set default rstudio preferences
ADD rstudio-prefs.json /etc/rstudio/

# Define default mount points
VOLUME /home/rstudio/workdir
WORKDIR /home/rstudio/workdir
ENV PATH="/usr/local/bin:${PATH}"
