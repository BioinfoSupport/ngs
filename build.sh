

# Build the container for the local machine architecture (for faster debuging)
docker build -t unigebsp/ngs ./

# Build the container for production (multiple target architectures)
docker buildx build --push --platform linux/arm64,linux/amd64 -t unigebsp/ngs ./

# Run the container
docker run --rm -it -v "$HOME/Documents/docker/:/home/rstudio/workdir" unigebsp/ngs bash

# Run the GUI
docker run --rm -p 8787:8787 -e DISABLE_AUTH=true -v "$HOME/Documents/docker/:/home/rstudio/workdir" unigebsp/ngs

