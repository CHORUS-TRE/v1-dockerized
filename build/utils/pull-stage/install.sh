#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

start-docker.sh
until docker info; do sleep 1; done

docker pull quay.io/keycloak/keycloak:21.1.2
docker pull postgres
docker pull nextcloud:24.0.12-fpm
docker pull postgres:14
docker pull redis:latest
docker pull registry.build.chorus-tre.ch/hip/app-in-browser/xpra-server:master
docker pull registry.build.chorus-tre.ch/hip/app-in-browser/filemanager:latest
docker pull registry.build.chorus-tre.ch/hip/app-in-browser/terminal_dip latest
docker pull registry.build.chorus-tre.ch/hip/app-in-browser/vscode latest
# docker pull registry.build.chorus-tre.ch/hip/app-in-browser/arx 3.9.1
docker pull registry.build.chorus-tre.ch/hip/app-in-browser/jupyterlab latest
docker pull registry.build.chorus-tre.ch/hip/app-in-browser/libreoffice latest

pids=$(pgrep supervisord)
kill $pids
sleep 2

#cp -r /var/lib/docker /root/var-lib-docker