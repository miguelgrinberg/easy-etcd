#!/bin/bash
CLUSTER_SIZE=${1:-1}
ETCD_HOST=${ETCD_HOST:-}
ETCD_CLUSTER=
for i in $(seq 1 $CLUSTER_SIZE); do
    echo Starting etcd container \#$i...
    CONTAINER=`docker run -d -e ETCD_HOST=$ETCD_HOST miguelgrinberg/easy-etcd`
    IP_ADDRESS=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CONTAINER`
    if [[ "$ETCD_CLUSTER" == "" ]]; then
        ETCD_CLUSTER=http://$IP_ADDRESS:2379
    else
    	ETCD_CLUSTER=$ETCD_CLUSTER,http://$IP_ADDRESS:2379
    fi
    sleep 5
    if [[ "$ETCD_HOST" == "" ]]; then
        ETCD_HOST=$IP_ADDRESS
    fi
done
echo ETCDCTL_PEERS=$ETCD_CLUSTER
