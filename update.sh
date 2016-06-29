#!/bin/bash
OWNPATH=$(dirname "$(readlink -f "$BASH_SOURCE")")
BUILDPATH=${OWNPATH}/arch
VARSFILE="${OWNPATH}/vars/main.yml"
source $BUILDPATH/env
echo "OWN=$OWNPATH"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	pushd ${BUILDPATH}
	versions=( */ )
	popd
fi
versions=( "${versions[@]%/}" )

cat > ${VARSFILE} <<EOF
target_qemu_dir: ${EMULATORDIR}/
binfmt_emulators:
EOF
for version in "${versions[@]}"; do
	cat >> ${VARSFILE} <<EOF
  - ${version}
EOF
done

cat >> ${VARSFILE} <<EOF
binfmt_rules:
EOF
for emulator in "${versions[@]}"; do
	if [ ! -f ${BUILDPATH}/${emulator}/binfmt ]; then
		echo "No binfmt rule found for ${emulator}."
		exit 1
	fi
	arch=$(echo ${emulator} | cut -f2 -d-)
	rule=$(cat ${BUILDPATH}/${emulator}/binfmt) 
        cat >> ${VARSFILE} <<EOF
  - '${rule}'
EOF
	sed -e 's/EMULATOR/'"$emulator"'/g' -i "" ${VARSFILE}
	sed -e 's_PATH_'"$EMULATORDIR"'_g' -i "" ${VARSFILE}
	if [ -f ${BUILDPATH}/${emulator}/base ]; then
		image=$(cat ${BUILDPATH}/${emulator}/base)
		cp ${OWNPATH}/Dockerfile.build ${BUILDPATH}/${emulator}/Dockerfile
		sed -e 's_BASE_'"$image"'_g' -i "" ${BUILDPATH}/${emulator}/Dockerfile
		sed -e 's+EMULATOR+'"$emulator"'+g' -i "" ${BUILDPATH}/${emulator}/Dockerfile
		sed -e 's_PATH_'"$EMULATORDIR"'_g' -i "" ${BUILDPATH}/${emulator}/Dockerfile	
	fi	
done

