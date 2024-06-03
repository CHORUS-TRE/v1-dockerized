#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

docker run -ti --volume ./stage5-files:/root/stage5-files --entrypoint /root/stage5-files/install.sh --privileged -p 8888:80 -p 8080:8080 -p 9001:9001 local/chorusv1-stage4


