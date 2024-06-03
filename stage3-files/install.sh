#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

mv /root/var-lib-docker /var/lib/docker

start-docker.sh
until docker info; do sleep 1; done

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

docker compose --env-file ../.env -f docker-compose.yml up -d || true

sleep 3

pids=$(pgrep supervisord)
kill $pids
sleep 10

#make occ c=maintenance:install 

