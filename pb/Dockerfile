FROM golang:1.19-alpine

ARG PB_VERSION=0.11.2

RUN apk add --no-cache \
    unzip \
    # this is needed only if you want to use scp to copy later your pb_data locally
    openssh

COPY ./pb/lib /pb/lib
RUN cd /pb/lib && \
    CGO_ENABLED=0 go build -o /pb/pocketbase src/main.go && \
    rm -rf /pb/lib

# Copy migration files
COPY ./pb/pb_migrations /pb/pb_migrations


EXPOSE 8080

# start PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]
