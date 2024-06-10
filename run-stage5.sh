#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

if [ "$NEXTCLOUD_VIRTUAL_HOST" != "" ]; then
    docker run -ti --volume ./stage5-files:/root/stage5-files -v ./${pwd}/var-lib-docker:/var/lib/docker --entrypoint /root/stage5-files/install.sh --privileged -p 8888:80 -p 8080:8080 -p 9001:9001 --env NEXTCLOUD_VIRTUAL_HOST=app-in-browser local/chorusv1-stage4
else
    docker run -ti --volume ./stage5-files:/root/stage5-files -v ./${pwd}/var-lib-docker:/var/lib/docker --entrypoint /root/stage5-files/install.sh --privileged -p 8888:80 -p 8080:8080 -p 9001:9001 local/chorusv1-stage4
fi

