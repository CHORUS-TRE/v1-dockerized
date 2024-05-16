#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

start-docker.sh
until docker info; do sleep 1; done


cd /root/frontend/nextcloud-docker
# TODO parametrize user pass?
docker compose --env-file ../.env -f docker-compose.yml up -d || true

echo "waiting for docker to be up"
sleep 120

docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ maintenance:install \
    --admin-user "nextcloud_admin_user" --admin-pass "nextcloud_admin_password" \
    --database "pgsql" --database-name "postgres_db" \
    --database-host "db" --database-user "postgres_user" --database-pass "postgres_password"

docker exec -i db psql -U postgres_user -d postgres_db -c "ALTER USER oc_nextcloud_admin_user WITH SUPERUSER;"
docker compose exec --user www-data app php occ maintenance:repair

python3 update_nextcloud_config.py

cd ../pm2

sudo npm install

cd ..


make install

# add custom nextcloud social login
make build-socialapp
make install-socialapp
make enable-socialapp

#launch keycloak
cd keycloak
# (updated .env.template nothing to do)
cp .env.template .env
docker compose up -d

# keycloak only reachable via set hostname (keycloak.local:8080)
# note: keycloak contraints extremely relaxed, to change TODO

# configure nextcloud social login
cd ..
cd nextcloud-docker
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add hip
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add epfl-esl
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add uka
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add vr-vis
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add ucl
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add chuc
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add amu-ns
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add chuv
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add amu-tng
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add aphm
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add chru-lille
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add chm
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add chuga
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add chu-lyon
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add fnusa
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add hus
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add chru-s
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add ou-sse
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add psmar
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add ucbl
docker compose --env-file ../.env -f docker-compose.yml exec --user www-data app php occ group:add umcu
docker compose --env-file ../.env -f docker-compose.yml up sociallogin_init

# TODO /etc/hosts get overwritten, 
# need to either put domains in dockerfile via net or add to entry point following:
# see https://stackoverflow.com/questions/27521678/etc-hosts-file-of-a-docker-container-gets-overwritten
echo "127.0.0.1 hip.local" >> /etc/hosts
echo "127.0.0.1 keycloak.local" >> /etc/hosts
echo "127.0.0.1 keycloak_backend.local" >> /etc/hosts

# killall dockerd
# sleep 1