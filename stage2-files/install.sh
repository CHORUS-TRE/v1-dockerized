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
docker pull registry.hbp.link/hip/app-in-browser/xpra-server:master
docker pull registry.hbp.link/hip/app-in-browser/filemanager:latest

pids=$(pgrep supervisord)
kill $pids
sleep 2

cp -r /var/lib/docker /root/var-lib-docker