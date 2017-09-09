FROM debian:latest

RUN apt-get update && apt-get install -y \
    aptly \
 && rm -rf /var/lib/apt/lists/*
