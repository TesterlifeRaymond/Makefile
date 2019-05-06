# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
BINARY_NAME=main
BINARY_UNIX=$(BINARY_NAME)_unix
NAME?="nil"


VERSION=1.0.0
BUILD=`date +%FT%T%z`
# Setup the -Idflags options for go build here,interpolate the variable values
LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.Build=${BUILD}"

all: test build install run deps setup

setup: 
	mkdir ${NAME}; cd ${NAME}; mkdir tests enti config core logic model; touch main.go
	for item in enti config core logic model
	do
		echo ${item}.go created
		touch ${item}/${item}.go
	done

build: test
	$(GOBUILD) ${LDFLAGS} -o $(BINARY_NAME) -v

test:
	$(GOTEST) -v ./...

clean:
	if [ -f ${BINARY} ] ; then rm -f ${BINARY_NAME} && rm -f ${BINARY_UNIX} ; fi
	$(GOCLEAN)

run:
	./$(BINARY_NAME)

deps: test
	$(GOGET) github.com/markbates/goth
	$(GOGET) github.com/markbates/pop

install:
	go install ${LDFLAGS}

# Cross compilation
build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 $(GOBUILD) -o $(BINARY_UNIX) -v
docker-build:
	docker run --rm -it -v "$(GOPATH)":/go -w /go/src/bitbucket.org/rsohlich/makepost golang:latest go build -o "$(BINARY_UNIX)" -v
