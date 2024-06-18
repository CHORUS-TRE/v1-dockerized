#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

#mv /root/var-lib-docker /var/lib/docker

start-docker.sh
until docker info; do sleep 1; done

# TODO /etc/hosts get overwritten, 
# need to either put domains in dockerfile via net or add to entry point following:
# see https://stackoverflow.com/questions/27521678/etc-hosts-file-of-a-docker-container-gets-overwritten
echo "127.0.0.1 hip.local" >> /etc/hosts
echo "127.0.0.1 keycloak.local" >> /etc/hosts
echo "127.0.0.1 keycloak_backend.local" >> /etc/hosts

cd /root
git clone --recurse-submodules https://github.com/HIP-infrastructure/frontend.git
cd frontend
git checkout --recurse-submodules feat/docker
cp .env.template .env

git clone https://github.com/HIP-infrastructure/nextcloud-docker.git
cd nextcloud-docker
git checkout feat/docker
cd ..

git clone https://github.com/HIP-infrastructure/nextcloud-social-login.git
cd nextcloud-social-login
git checkout feat/docker
cd ..

git clone https://github.com/HIP-infrastructure/keycloak.git
cd keycloak
git checkout feat/docker
cd ..

cd nextcloud-docker
cp caddy/Caddyfile.template caddy/Caddyfile

curl https://raw.githubusercontent.com/HIP-infrastructure/nextcloud-inotifyscan/hip/nextcloud-inotifyscan > nextcloud/nextcloud-inotifyscan
chmod +x nextcloud/nextcloud-inotifyscan

cp .env.template .env
cat .env >> ../.env

./fix_crontab.sh

# setup caddy & db
docker compose up -d db
echo "Waiting for caddy and db to be ready, waiting 60sec..."
sleep 30
docker compose down

# previously make install-nextcloud
export NC_DATA_FOLDER=/mnt/nextcloud-dp/nextcloud
sudo mkdir -p /var/www
[ ! -L /var/www/html ] && sudo ln -sf ${NC_DATA_FOLDER} /var/www/html || true
sudo chown -R www-data:www-data /var/www/html
sudo rm -rf ${NC_DATA_FOLDER}/core/skeleton
sudo mkdir -p ${NC_DATA_FOLDER}/core/skeleton
sudo cp ../hip/skeleton/* ${NC_DATA_FOLDER}/core/skeleton
sudo chown -R www-data:www-data ${NC_DATA_FOLDER}/core/skeleton
docker compose --env-file ../.env -f docker-compose.yml build cron
sudo chown root:root crontab
docker compose --env-file ../.env -f docker-compose.yml up -d || true

echo "waiting for docker to be up"
sleep 60

sudo rm -rf /mnt/nextcloud-dp/php-settings
sudo cp -r ../php-settings /mnt/nextcloud-dp

docker compose down
docker compose --env-file ../.env -f docker-compose.yml up -d || true

echo "waiting for docker to be up"
sleep 60

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

cd ..
make nextcloud-config

cd ..
git clone https://github.com/HIP-infrastructure/app-in-browser.git
cd app-in-browser
git checkout feat/docker

mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
   "default-address-pools":[
      {
         "base":"172.17.0.0/12",
         "size":20
      },
      {
         "base":"192.168.0.0/16",
         "size":24
      }
   ]
}
EOF

# restart dockerd

cp hip.config.docker.yml hip.config.yml
cp backend/backend.env.template backend/backend.env

./scripts/installrequirements.sh
# ./scripts/restrictnetwork.sh
#./scripts/downloadall.py
# TODO replace by env vars
./scripts/gencreds.sh backend_username backend_password 
./scripts/installbackend.sh


cd ../frontend
mkdir -p /mnt/collab
make install-ghostfs
CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' ghostfs/cert.pem)
sed -i -e "s|your_cert_private|$CERT|g" /root/app-in-browser/hip.config.yml
sed -i -e "s|your_cert_collab|$CERT|g" /root/app-in-browser/hip.config.yml

pm2 save

sleep 3

pm2 kill

pids=$(pgrep supervisord)
kill $pids
sleep 10


cp_backup() {
   CP_PATH=$1
   mkdir -p /backup

   cp -Rp "$CP_PATH" "/backup/$CP_PATH"
}

cp_backup /mnt
cp_backup /root/frontend/keycloak/postgres_data
cp_backup /root/frontend/nextcloud-docker/db
cp_backup /root/frontend/nextcloud-docker/redis/data
cp_backup /root/frontend/gateway/redis/data


