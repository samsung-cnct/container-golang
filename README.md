[![pipeline status](https://git.cnct.io/common-tools/samsung-cnct_container-golang/badges/master/pipeline.svg)](https://git.cnct.io/common-tools/samsung-cnct_container-golang/commits/master)

# container-golang

This is a container that provides a build environment for golang apps. It is ported from a golang tools repository found [here](https://github.com/samsung-cnct/golang-tools/tree/master/goglide-container).

## How To Use

The intended use for this container is to provide a consistent golang test environment for CI for golang projects. It provides [gosu](https://github.com/tianon/gosu) and [dep](https://github.com/golang/dep) inside a standardized golang container. 

Gosu is used in the entrypoint.sh script to add a local user.

The `dep` functionality is a flexible dependency manager that identifies the imported dependencies in the Golang code, imports them, and sets them in a `vendor` directory. This way, CI can run and test the Go code in any project inside this container. Dep is, per its creators, still in the experimental state, but it is actively being improved and developed, and is by far the best dependency management tool out there for CI purposes. The alternative, `godep`, would require each and every project to be checked in to CI with a `vendor` directory already created; `dep` creates one inside the golang container during each CI run.

Additionally the container adds [godoc](https://godoc.org/golang.org/x/tools/cmd/godoc) as well as [gometalinter](https://github.com/alecthomas/gometalinter) to have access to testing tools.

The original golang image is from the [Docker Hub golang image](https://hub.docker.com/_/golang/).


### Setting up CI in your project

In your Golang project's .gitlab-ci.yml, use this container as follows. 

In your build and/or test stage, the golang container image can be set with the `image` key:

```
image: quay.io/samsung-cnct/golang-container:latest
```

CI places your files in the container's top level directory, at `$CI_PROJECT_PATH` (most likely `samsung-cnct/<golang-project-name>`), which is not in the container's `$GOPATH` at `/go`. To place it in the go source directory, create a symlink into the project from the container's `$GOPATH/src`. Make sure to use the project's absolute path to create the symlink. For reference on Gitlab's built-in CI variables, see [here](https://docs.gitlab.com/ce/ci/variables/README.html).

```
script:
  - ln -s /$CI_PROJECT_PATH $GOPATH/src && cd $GOPATH/src/$CI_PROJECT_NAME
```

Install all linters via gometalinter:

```
(script:)
    ...
    - gometalinter.v2 --install
```

Note: if your code has no checked in dependencies, you can add them with `dep init`; otherwise run `dep ensure` to check for differences between your Gopkg.lock and Gopkg.toml - documentation [here](https://github.com/golang/dep#usage)

```
(script:)
    ...
    - dep init // do not run this if you already have a vendor folder
    - dep ensure
```

This setup should enable you to run all the standard Go tools, including `go build`, in a standardized context.

Finally, for use of the built golang project and/or binary in subsequent stages, create an [artifact] of the created files: 

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
  - gometalinter.v2 --install
  - ln -s /$CI_PROJECT_PATH $WORKDIR && cd $WORKDIR/$CI_PROJECT_NAME
  - dep init // do not run this if you already have a vendor folder
  - dep ensure
  - gometalinter.v2 - gometalinter.v2 \
    --disable-all \
		--enable=vet \
		--enable=gofmt \
		--enable=golint \
		--enable=gosimple \
		--sort=path \
		--aggregate \
		--vendor \
		--tests \
		./...
  - go test
  - go build $CI_PROJECT_NAME.go // or possibly main.go
  artifacts:
    untracked: true
```

## Use in local environment

For greater understanding of how this container works, you can use it locally on your Mac, or from inside another container, to build a golang program as follows:

1. Navigate to your golang project's folder.

2. Place your project's package name in a bash variable:
    `package_name=<the path from the go directory to your current working directory, starting with /src>`
    You will need this variable to tell the container which directory to build in.

3. To run the container, we need to mount the local GOPATH to the container's GOPATH (located at `/go`). The basic command will then look like this:

    `docker run --rm -v ${GOPATH}:/go -w /go${package_name} quay.io/samsung_cnct/golang-container:latest`

Verify the go version:

`docker run --rm -v ${GOPATH}:/go -w /go${package_name} quay.io/samsung_cnct/golang-container:latest go version`

To run or build  your tool with the container, run 

`docker run --rm -v ${GOPATH}:/go -w /go${package_name} quay.io/samsung_cnct/golang-container:latest go build <mytool.go>`

This will build a golang binary inside the build container and place it (via the mounted volume) into your current local directory. 

*Special instructions for cross-compilation to OSX*
Be aware that unless your local environment is a Linux environment, the above built binary cannot execute on a Mac. You must pass env variables telling the build to build for the OSX environment.

`docker run --rm -v ${GOPATH}:/go -w /go${package_name} quay.io/samsung_cnct/golang-container:latest env GOOS=darwin GOARCH=amd64 go build <mytool.go>`

Reference for the golang DockerHub container, including cross-compilation instructions, can be found [here](https://hub.docker.com/_/golang/)