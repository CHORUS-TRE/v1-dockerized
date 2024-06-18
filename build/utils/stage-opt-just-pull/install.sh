#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"


cd /root
cd frontend
git pull --recurse-submodules

cd nextcloud-docker
git pull
cd ..

cd nextcloud-social-login
git pull
cd ..

cd keycloak
git pull
cd ..



