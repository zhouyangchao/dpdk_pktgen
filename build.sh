#!/bin/bash

set -x -e

WORK_DIR=$(dirname $(readlink -f $0))/

source ${WORK_DIR}/config

[ -z "${DPDK_VER}" -o -z "${PKTGEN_VER}" ] && {
	echo "must config DPDK_VER and PKTGEN_VER in config"
	exit 1
}

DPDK_URL="http://fast.dpdk.org/rel/dpdk-${DPDK_VER}.tar.xz"
PKTGEN_URL="https://git.dpdk.org/apps/pktgen-dpdk/snapshot/pktgen-dpdk-pktgen-${PKTGEN_VER}.tar.xz"

DPDK_DIR=${WORK_DIR}/dpdk-stable-${DPDK_VER}
PKTGEN_DIR=${WORK_DIR}/pktgen-dpdk-pktgen-${PKTGEN_VER}

[ ! -d ${DPDK_DIR} ] && {
	wget -O dpdk-${DPDK_VER}.tar.xz ${DPDK_URL}
	tar xf dpdk-${DPDK_VER}.tar.xz
}

[ ! -d ${PKTGEN_DIR} ] && {
	wget -O pktgen-dpdk-pktgen-${PKTGEN_VER}.tar.xz ${PKTGEN_URL}
	tar xf pktgen-dpdk-pktgen-${PKTGEN_VER}.tar.xz
}


export RTE_SDK=${WORK_DIR}/${DPDK_DIR}
export RTE_TARGET=${RTE_TARGET:-x86_64-native-linuxapp-gcc}

make -C ${RTE_SDK} -j32 install T=${RTE_TARGET}
make -C ${PKTGEN_DIR} -j32

PKTGEN_PROG=${PKTGEN_DIR}/app/${RTE_TARGET}/pktgen

[ -f "$PKTGEN_PROG" ] && {
	echo "DPDK pktgen build success, pktgen: ${PKTGEN_PROG}"
	echo "sample start: ${PKTGEN_PROG} -l 0,1 -n 4 --proc-type auto --log-level 7 --file-prefix pg -- -T -P -m [1:1].0"
}
