#!/usr/bin/env bash
grpcurl \
    -d '{"name": "Mr. GrpCurl"}' \
    -import-path . \
    -plaintext \
    -proto hello.proto \
    localhost:8080 \
    "hello.HelloService/SayHello"