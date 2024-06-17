# Add to 3rd install.sh

```bash
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
# note: keycloak contraints extremely relaxed, to change

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


# -----------------------------------------------------
# -----------------------------------------------------
# -----------------------------------------------------
# CONT: 

# MISSING 
cd ..
make nextcloud-config


cd ..
git clone https://github.com/HIP-infrastructure/app-in-browser.git
cd app-in-browser
git checkout feat/docker

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
./scripts/downloadall.py
# TODO replace by env vars
./scripts/gencreds.sh backend_username backend_password 
./scripts/installbackend.sh


cd ..
mkdir -p /mnt/collab
make install-ghostfs
CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' ghostfs/cert.pem)
sed -i -e "s|your_cert_private|$CERT|g" /root/app-in-browser/hip.config.yml
sed -i -e "s|your_cert_collab|$CERT|g" /root/app-in-browser/hip.config.yml


# TODO to allow minimal exterior run
OK - Change nextcloud allowed host
OK - change keycloak host
OK   - change sociallogin redirect url to match new host
NONEED - allow any url for xpra? 

# TODO to allow a bit of cust.
- change default nextcloud user/pass 
- change default nextcloud admin creds
- change keycloak admin pass
- persist state

```