# ngs

This is a docker container with tools to analyse NGS data.

## Run a shell in the container
```
docker run --rm -it -v "$PWD:/home/rstudio/workdir" unigebsp/ngs bash

singularity exec "docker://unigebsp/ngs" bash
```

## Run the GUI (Rstudio server)
```
docker run --rm -p 8787:8787 -e DISABLE_AUTH=true -v "$PWD:/home/rstudio/workdir" unigebsp/ngs
```



## Build the container
```
docker buildx build --push --platform linux/arm64,linux/amd64 -t unigebsp/ngs ./
```




