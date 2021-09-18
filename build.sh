#!/bin/bash

# Build
docker build . -t docker-oozou:dev

# Tag
docker tag docker-oozou:dev pongsakm2007/interview-oozou:dev

# Push
docker push pongsakm2007/interview-oozou:dev

