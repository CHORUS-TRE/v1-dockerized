#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

export DOCKER_TLS_CERTDIR=""

echo "127.0.0.1 hip.local" >> /etc/hosts
echo "127.0.0.1 keycloak.local" >> /etc/hosts
echo "127.0.0.1 keycloak_backend.local" >> /etc/hosts

#mv /root/var-lib-docker /var/lib/docker

start-docker.sh
until docker info; do sleep 1; done

sleep 2

pm2 resurrect

cd /root/frontend
docker compose --env-file .env -f docker-compose.yml up -d || true

sleep 1

cd /root/frontend/nextcloud-docker
docker compose --env-file ../.env -f docker-compose.yml up -d || true

sleep 1

cd /root/frontend/keycloak
docker compose --env-file .env -f docker-compose.yml up -d || true


tail -f /dev/null