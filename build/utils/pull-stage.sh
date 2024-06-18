#! /bin/bash


set -e
set -o xtrace
# cd "${0%/*}"

docker run -ti --volume ./pull-stage:/root/pull-stage -v ./${pwd}/var-lib-docker:/var/lib/docker --entrypoint ./pull-stage/install.sh --privileged local/chorusv1-stage1
# export CONTAINER_ID=`docker ps -lq`
# docker commit $CONTAINER_ID local/chorusv1-stage2
