[![pipeline status](https://git.cnct.io/common-tools/samsung-cnct_container-golang/badges/master/pipeline.svg)](https://git.cnct.io/common-tools/samsung-cnct_container-golang/commits/master)

# container-golang

This is a container that provides a build environment for golang apps. It is ported from a golang tools repository found [here](https://github.com/samsung-cnct/golang-tools/tree/master/goglide-container).

## How To Use

The intended use for this container is to provide a consistent golang test environment for CI for golang projects. It provides [gosu](https://github.com/tianon/gosu) and [dep](https://github.com/golang/dep) inside a standardized golang container. 

Gosu is used in the entrypoint.sh script to add a local user.

The `dep` functionality is a flexible dependency manager that identifies the imported dependencies in the Golang code, imports them, and sets them in a `vendor` directory. This way, CI can run and test the Go code in any project inside this container. Dep is, per its creators, still in the experimental state, but it is actively being improved and developed, and is by far the best dependency management tool out there for CI purposes. The alternative, `godep`, would require each and every project to be checked in to CI with a `vendor` directory already created; `dep` creates one inside the golang container during each CI run.

The original golang image is from the [Docker Hub golang image](https://hub.docker.com/_/golang/).


### Setting up CI in your project

In your Golang project's .gitlab-ci.yml, use this container as follows. 

In your build and/or test stage, the golang container image can be set with the `image` key:

```
image: quay.io/samsung-cnct/golang-container:latest
```

Because CI places your files in the container's `samsung-cnct` directory, rather than in the container's GOPATH at `/go/src/github.com`, create a symlink into to the project, and change into the linked direcory:

```
script:
  - ln -s /samsung-cnct/<my_golang_project> /go/src/github.com && cd /go/src/github.com/<my_golang_project>
```

Add your dependencies with `dep`:

```
(script:)
    - ...
    - dep init
    - dep ensure
```

Thereafter, you may execute any go tools desired including `go build`.

Finally, for use of the built golang project and/or binary in subsequent stages, create an artifact of the created files: 

```
artifacts:
    untracked: true
```

_Here is an example of a CI build stage using the golang container:_

```
stages:
  - build

build:
  stage: build
  image: quay.io/samsung-cnct/golang-container:latest
  script:
  - ln -s /samsung-cnct/<golang_project> /go/src && cd /go/src/<golang_project>
  - dep init
  - dep ensure
  - go vet -v <golang_project>.go
  - golint <golang_project>.go
  - go test
  - go build /go/src/github.com/<golang_project>/<golang_project>.go
  artifacts:
    untracked: true
```

## Use in local environment

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