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

function set_trusted_domains {
    sleep 50
    current_domain=$(docker exec --user www-data cron php occ config:system:get trusted_domains 1)
    if [ "$current_domain" != "$NEXTCLOUD_VIRTUAL_HOST" ]; then
        docker exec --user www-data cron php occ config:system:set trusted_domains 1 --value="$NEXTCLOUD_VIRTUAL_HOST"
    fi
}

cd /root/frontend/nextcloud-docker
docker compose --env-file ../.env -f docker-compose.yml up -d || true
set_trusted_domains &

sleep 1

cd /root/frontend/keycloak
docker compose --env-file .env -f docker-compose.yml up -d || true


tail -f /dev/null