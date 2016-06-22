#!/bin/bash
OWNPATH=$(dirname "$(readlink -f "$BASH_SOURCE")")
source $OWNPATH/env

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	pushd ${OWNPATH}
	versions=( */ )
	popd
fi
versions=( "${versions[@]%/}" )

WRKDIR=$(mktemp -d)
for emulator in "${versions[@]}"; do
	if [ -f ${OWNPATH}/${emulator}/Dockerfile -a -f ${OWNPATH}/${emulator}/base ]; then
		arch=$(echo ${emulator} | cut -f2 -d-)
		host=$(uname -m)
		if [ ${arch} != ${host} ]; then
                	base=$(cat ${OWNPATH}/${emulator}/base)
			mkdir ${WRKDIR}/${emulator}
			cp -ar ${OWNPATH}/${emulator}/* ${WRKDIR}/${emulator}
			cp ${EMULATORDIR}/${emulator}-static ${WRKDIR}/${emulator}
			# TBD Append Custom Dockerfiles
			sudo docker rmi ${arch}/qemu-base
			sudo docker build --rm -t ${base}-multiarch:${host}_${arch} ${WRKDIR}/${emulator}
		fi
	fi
done

rm -rf ${WRKDIR}
