#! /bin/bash


cd "${0%/*}"

docker build -f stage1-files/Dockerfile -t local/chorusv1-stage1 ./stage1-files