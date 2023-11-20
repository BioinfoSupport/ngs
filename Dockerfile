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
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/*;

# Install R packages
ADD install.R /tmp
RUN R --no-save --no-restore -e 'source("/tmp/install.R");install_cran()'
RUN R --no-save --no-restore -e 'source("/tmp/install.R");install_bioc()'
#RUN R --no-save --no-restore -e 'source("/tmp/install.R");install_ml()'


ENV REPOPATH=/home/rstudio/repository
ADD ./ $REPOPATH
ENV PATH=$PATH:$REPOPATH/local/bin/


# Define default mount points
VOLUME /home/rstudio/workdir
WORKDIR /home/rstudio/workdir

