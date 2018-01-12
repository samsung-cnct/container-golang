[![pipeline status](https://git.cnct.io/common-tools/samsung-cnct_container-golang/badges/master/pipeline.svg)](https://git.cnct.io/common-tools/samsung-cnct_container-golang/commits/master)

# container-golang

This is a container that provides a build environment for golang apps. It is ported from a golang tools repository found [here](https://github.com/samsung-cnct/golang-tools/tree/master/goglide-container).

## How To Use

The intended use for this container is as a build container for solas-apps (coming soon). It provides gosu with a standardized golang container, and an entrypoint.sh script that takes command line arguments.

The original golang image is from the [Docker Hub golang image](https://hub.docker.com/_/golang/).

For greater understanding of how this container works, you can use it locally to build a golang program as follows:
