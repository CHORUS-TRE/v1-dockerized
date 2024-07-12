#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

export DOCKER_TLS_CERTDIR=""

echo "127.0.0.1 hip.local" >> /etc/hosts
echo "127.0.0.1 keycloak.local" >> /etc/hosts
echo "127.0.0.1 keycloak_backend.local" >> /etc/hosts

if [ ! -e /mnt/initial_setup_done ]; then
    restore_backup() {
        CP_PATH=$1
        mkdir -p "/backup$CP_PATH"
        mkdir -p "$CP_PATH"

        cp -RTp "/backup$CP_PATH" "$CP_PATH"
    }

    restore_backup /mnt/
    restore_backup /root/frontend/keycloak/postgres_data/
    restore_backup /root/frontend/nextcloud-docker/db/
    restore_backup /root/frontend/nextcloud-docker/redis/data/
    restore_backup /root/frontend/gateway/redis/data/

    echo "1" > /mnt/initial_setup_done
fi
#mv /root/var-lib-docker /var/lib/docker

start-docker.sh
until docker info; do sleep 1; done

sleep 2

# Add this function to your .bashrc or .bash_profile
pull_image_if_not_present() {
    IMAGE=$1
    TAG=$2

    if [[ -z "$IMAGE" || -z "$TAG" ]]; then
        echo "Usage: pull_image_if_not_present <image> <tag>"
        return 1
    fi

    # Check if the image:tag exists locally
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE}:${TAG}$"; then
        echo "Image ${IMAGE}:${TAG} already exists locally. Skipping pull."
    else
        echo "Image ${IMAGE}:${TAG} not found locally. Pulling image."
        docker pull ${IMAGE}:${TAG}
    fi
}

pull_image_if_not_present quay.io/keycloak/keycloak 21.1.2
pull_image_if_not_present postgres latest
pull_image_if_not_present nextcloud 24.0.12-fpm
pull_image_if_not_present postgres 14
pull_image_if_not_present redis latest
pull_image_if_not_present registry.hbp.link/hip/app-in-browser/xpra-server master
pull_image_if_not_present registry.hbp.link/hip/app-in-browser/filemanager latest
pull_image_if_not_present registry.hbp.link/hip/app-in-browser/terminal_dip latest
pull_image_if_not_present registry.hbp.link/hip/app-in-browser/vscode latest
# pull_image_if_not_present registry.hbp.link/hip/app-in-browser/arx 3.9.1
pull_image_if_not_present registry.hbp.link/hip/app-in-browser/jupyterlab latest
pull_image_if_not_present registry.hbp.link/hip/app-in-browser/libreoffice latest

pm2 resurrect
cd /root/frontend
pm2 start pm2/ecosystem.config.js
cd /root/app-in-browser
pm2 start pm2/ecosystem.config.js

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

if [ -e "/root/run-files/logo.png" ]; then
    mkdir -p /mnt/nextcloud-dp/nextcloud/shared
    cp /root/run-files/logo.png /mnt/nextcloud-dp/nextcloud/shared
fi


tail -f /dev/null