#!/bin/sh
ETCD_NAME=${ETCD_NAME:-`hostname`}
ETCD_CLIENT_PORT=${ETCD_CLIENT_PORT:-2379}
ETCD_PEER_PORT=${ETCD_PEER_PORT:-2380}
ETCD_CLUSTER_TOKEN=${ETCD_CLUSTER_TOKEN:-etcd-cluster-token}
ETCD_LISTEN_IP_ADDRESS=${ETCD_LISTEN_IP_ADDRESS:-0.0.0.0}
MY_IP_ADDRESS=`ip route get 1 | awk '{print $NF; exit}'`
if [ "$ETCD_HOST" = "" ]; then
    ETCD_CLUSTER=$ETCD_NAME=http://$MY_IP_ADDRESS:$ETCD_PEER_PORT
    ETCD_CLUSTER_STATE=new
else
    for i in 1 2 3 4 5; do
    	ETCD_CLUSTER=`etcdctl --no-sync --endpoint http://$ETCD_HOST:$ETCD_CLIENT_PORT member add $ETCD_NAME http://$MY_IP_ADDRESS:$ETCD_PEER_PORT | awk 'BEGIN { FS = "\"" }; { if ($1 == "ETCD_INITIAL_CLUSTER=") print $2 }'`
        if [[ "$ETCD_CLUSTER" != "" ]]; then
            break
        fi
        sleep $((5 * $i))
    done
    ETCD_CLUSTER_STATE=existing
fi
echo etcd --name $ETCD_NAME --advertise-client-urls http://$MY_IP_ADDRESS:$ETCD_CLIENT_PORT --listen-client-urls http://$ETCD_LISTEN_IP_ADDRESS:$ETCD_CLIENT_PORT --initial-advertise-peer-urls http://$MY_IP_ADDRESS:$ETCD_PEER_PORT --listen-peer-urls http://$ETCD_LISTEN_IP_ADDRESS:$ETCD_PEER_PORT --initial-cluster-token $ETCD_CLUSTER_TOKEN --initial-cluster $ETCD_CLUSTER --initial-cluster-state $ETCD_CLUSTER_STATE
exec etcd --name $ETCD_NAME --advertise-client-urls http://$MY_IP_ADDRESS:$ETCD_CLIENT_PORT --listen-client-urls http://$ETCD_LISTEN_IP_ADDRESS:$ETCD_CLIENT_PORT --initial-advertise-peer-urls http://$MY_IP_ADDRESS:$ETCD_PEER_PORT --listen-peer-urls http://$ETCD_LISTEN_IP_ADDRESS:$ETCD_PEER_PORT --initial-cluster-token $ETCD_CLUSTER_TOKEN --initial-cluster $ETCD_CLUSTER --initial-cluster-state $ETCD_CLUSTER_STATE
