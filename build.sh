#!/usr/bin/env bash
##
# Settings

# abort on error
# @see https://stackoverflow.com/questions/821396/aborting-a-shell-script-if-any-command-returns-a-non-zero-value
set -e

# abort when a non-existing variable is expanded, and show the error and line
# @see https://unix.stackexchange.com/questions/228331/avoid-running-the-script-if-a-variable-is-not-defined
set -o nounset

# also abort immediately in case one command in a pipe fails a.k.a. "pipefail"
# @see https://stackoverflow.com/questions/821396/aborting-a-shell-script-if-any-command-returns-a-non-zero-value
set -o pipefail

# logs all actions and variables
set -o xtrace

##
# Variables
APPLICATION_BINARY=helloserver

##
# 0. clear working directory
rm --force "${APPLICATION_BINARY}"

##
# 1. generate Go code from .proto file
protoc \
    --go_out=. \
    --go-grpc_out=. \
    hello.proto

##
# 2. fetch dependencies using go mod
go mod download -x
go mod verify

##
# 3. build binary
go build -o "${APPLICATION_BINARY}" helloserver.go
