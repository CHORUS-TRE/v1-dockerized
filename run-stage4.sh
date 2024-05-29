#! /bin/bash


set -e
set -o xtrace
cd "${0%/*}"

docker run -ti --volume ./stage4-files:/root/stage4-files -v $(pwd)/var-lib-docker:/var/lib/docker --entrypoint /root/stage4-files/install.sh --privileged local/chorusv1-stage3


