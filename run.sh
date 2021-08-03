#!/bin/bash

set -x -e

WORK_DIR=$(dirname $(readlink -f $0))/

source ${WORK_DIR}/config

[ -z "${DPDK_VER}" -o -z "${PKTGEN_VER}" ] && {
	echo "must config DPDK_VER and PKTGEN_VER in config"
	exit 1
}

DPDK_DIR=${WORK_DIR}/dpdk-stable-${DPDK_VER}
PKTGEN_DIR=${WORK_DIR}/pktgen-dpdk-pktgen-${PKTGEN_VER}

export RTE_SDK=${DPDK_DIR}
export RTE_TARGET=${RTE_TARGET:-x86_64-native-linuxapp-gcc}

PKTGEN_PROG=${PKTGEN_DIR}/app/${RTE_TARGET}/pktgen

modprobe vfio-pci

IFS=" " read -r -a devices <<<"$DEVICES"

for device in "${devices[@]}"
do
	${RTE_SDK}/usertools/dpdk-devbind.py -b vfio-pci $device
	devices_str="$devices_str -w $device"
done

${PKTGEN_PROG} -l ${LCORE_LIST} -n 4 --proc-type auto --log-level 7 --file-prefix pg $devices_str -- -T -P -m ${MAPS}
