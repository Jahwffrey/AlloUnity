#!/bin/bash

if [ -x "$(command -v greadlink)" ]; then
	dir=$(dirname "$(greadlink -f "$0")")
else
	dir=$(dirname "$(readlink -f "$0")")
fi

commit=$(git log -n 1 --pretty=format:"%ci %H" | tr : - | tr \  _)

if [ "${OSTYPE}" = "msys" ]; then
	echo "Uploading AlloUnity to Unity rendering machine ..."
	ssh -f -N -M -S /tmp/unity_upload -L 0.0.0.0:60001:192.168.10.250:22 nonce
	ssh -p 60001 localhost "if not exist Desktop\\AlloUnity\\$commit mkdir Desktop\\AlloUnity\\$commit" > /dev/null
	scp -P 60001 -r ${dir}/../Bin/* localhost:Desktop/AlloUnity/$commit/
	ssh -p 60001 localhost "if exist Desktop\\AlloUnity\\latest rmdir Desktop\\AlloUnity\\latest" > /dev/null
	ssh -p 60001 localhost "mklink /D Desktop\\AlloUnity\\latest $commit" > /dev/null
	echo "Done!"
	echo "Uploading Unity builds to Unity rendering machine ..."
	ssh -p 60001 localhost "if not exist \"Desktop\\Unity\\ Builds\\$commit\" mkdir \"Desktop\\Unity Builds\\$commit\"" > /dev/null
	scp -P 60001 -r ${dir}/../../Unity\ Builds/* localhost:Desktop/Unity\\\ Builds/$commit/
	ssh -p 60001 localhost "if exist \"Desktop\\Unity Builds\\latest\" rmdir \"Desktop\\Unity Builds\\latest\"" > /dev/null
	ssh -p 60001 localhost "mklink /D \"Desktop\\Unity Builds\\latest\" $commit" > /dev/null
	ssh -S /tmp/unity_upload -O exit nonce  > /dev/null
	echo "Done!"
elif [ "${OSTYPE}" = "linux-gnu" ]; then
	echo "Uploading AlloUnity to AlloSphere rendering machine ..."
	ssh -f -N -M -S /tmp/unity_upload -L 0.0.0.0:60001:gr01:22 nonce
	ssh -p 60001 sphere@localhost "mkdir tibor/AlloUnity/${commit}" > /dev/null
	scp -P 60001 -r ${dir}/../Bin/* sphere@localhost:tibor/AlloUnity/$commit/
	ssh -p 60001 sphere@localhost "ln -fs $commit/ tibor/AlloUnity/latest" > /dev/null
	ssh -p 60001 sphere@localhost "tibor/tree_rsync.py tibor/AlloUnity" > /dev/null
	ssh -S /tmp/unity_upload -O exit nonce > /dev/null
	echo "Done!"
fi
