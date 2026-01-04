ARG GO_VERSION=1.25.5
ARG OS_FLAVOR=trixie

FROM golang:${GO_VERSION}-${OS_FLAVOR}

ARG USERNAME=vscode
ARG USER_GID=1000
ARG USER_UID=1000

ARG PROJECT_NAME=grpc-poc-golang-server
ARG PROJECT_DIR=/home/${USERNAME}/${PROJECT_NAME}

# update OS and install needed packages
RUN apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --yes \
        git \
        mc \
        protobuf-compiler \
        sudo \
        && \
    apt-get clean autoclean && \
    apt-get autoremove --yes

COPY --from=fullstorydev/grpcurl /bin/grpcurl /bin/grpcurl

# setup user
RUN echo "creating user ${USERNAME} with uid=${USER_UID} and gid=${USER_GID}" && \
    groupadd \
        --gid ${USER_GID} \
        ${USERNAME} && \
    useradd \
        --create-home \
        --gid ${USER_GID} \
        --shell /bin/bash \
        --uid ${USER_UID} \
        ${USERNAME} && \
    mkdir \
        --parents \
        /etc/sudoers.d && \
    echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# only work in user context
USER ${USERNAME}
WORKDIR ${PROJECT_DIR}

RUN mkdir \
    --parents \
    /home/${USERNAME}/.cache/go-build \
    ${PROJECT_DIR}

# install go tools
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# use golang build cache
VOLUME /go/pkg
VOLUME /home/${USERNAME}/.cache/go-build
