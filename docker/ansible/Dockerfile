FROM python:3.12-alpine

RUN apk add --no-cache bash openssh-client \
  && pip install --no-cache-dir ansible-core==2.17.10

WORKDIR /workspace
