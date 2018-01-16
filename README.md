[![pipeline status](https://git.cnct.io/common-tools/samsung-cnct_container-golang/badges/master/pipeline.svg)](https://git.cnct.io/common-tools/samsung-cnct_container-golang/commits/master)

# container-golang

This is a container that provides a build environment for golang apps. It is ported from a golang tools repository found [here](https://github.com/samsung-cnct/golang-tools/tree/master/goglide-container).

## How To Use

The intended use for this container is as a build container for solas-apps (coming soon). It provides gosu with a standardized golang container, and an entrypoint.sh script that takes command line arguments.

The original golang image is from the [Docker Hub golang image](https://hub.docker.com/_/golang/).

For greater understanding of how this container works, you can use it locally on your Mac, or from inside another container, to build a golang program as follows:

1. Navigate to your golang project's folder.

2. Create two bash variables:
    1. `go_dir=<your local gopath>`
    2. `build_dir=<the path from the go directory to your current working directory, starting with /src>`
    You will need these variable to mount a volume to the container, and then tell the container which directory to build in.

3. To run the container, the basic command will then look like this:

    `docker run --rm -v ${go_dir}:/go -w /go${build_dir} quay.io/samsung_cnct/golang-container:latest`

Verify the go version:

`docker run --rm -v ${go_dir}:/go -w /go${build_dir} quay.io/samsung_cnct/golang-container:latest go version`

To run or build  your tool with the container, run 

`docker run --rm -v ${go_dir}:/go -w /go${build_dir} quay.io/samsung_cnct/golang-container:latest go build <mytool.go>`

This will build a golang binary inside the build container and place it (via the mounted volume) into your current local directory. 

*Special instructions for cross-compilation to OSX*
Be aware that unless your local environment is a Linux environment, the above built binary cannot execute on a Mac. You must pass env variables telling the build to build for the OSX environment.

`docker run --rm -v ${go_dir}:/go -w /go${build_dir} quay.io/samsung_cnct/golang-container:latest env GOOS=darwin GOARCH=amd64 go build <mytool.go>`

Reference for the golang DockerHub container, including cross-compilation instructions, can be found [here](https://hub.docker.com/_/golang/)