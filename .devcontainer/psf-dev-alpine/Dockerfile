FROM alpine

RUN apk --no-cache --update add \
    curl \
    git \
    shunit2 \
  &&addgroup -g 1000 vscode \
  && adduser -u 1000 -G vscode --disabled-password vscode

USER vscode
