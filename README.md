# easy-etcd

This repository provides an easy way to deploy
[etcd](https://github.com/coreos/etcd), as Docker containers or as standalone
processes.

## Deploying an etcd cluster manually with Docker

To deploy the first etcd node:

    docker run -d -p 2379:2379 -p 2380:2380 miguelgrinberg/easy-etcd

Alternatively, you can deploy the node without mapped ports, so then the
service can only be accessed from inside the Docker host:

    docker run -d miguelgrinberg/easy-etcd

Assuming the `FIRST_ETCD_IP_ADDRESS` variable is set to the IP address of the
first etcd node, you can deploy a second node as follows:

    docker run -d -e ETCD_HOST=$FIRST_ETCD_IP_ADDRESS miguelgrinberg/easy-etcd

You repeat the above command to add as many more nodes as you want!

Remember that the whole point of having a cluster is to avoid failure, so make
sure you use multiple Docker hosts. Having all etcd nodes in the same Docker
host is not going to help if the host goes down.

## Scripted Docker deployment

The `make-etcd-cluster.sh` script demonstrates how the steps in the previous
section can be automated.

To start a 3-node cluster:

    ./make-etcd-cluster.sh 3
    ETCDCTL_PEERS=http://172.17.0.2:2379,http://172.17.0.3:2379,http://172.17.0.4:2379

The output of the script is the environment variable that needs to be set to
configure `etcdctl` to talk to the cluster.

Note: This script is meant for development or demonstration purposes only, as
it does not build a robust cluster across multiple Docker hosts.

## Deploying etcd without Docker

The `boot.sh` script can be used to deploy etcd as a regular process. The
etcd service binaries must be installed before using this script.

To deploy the first etcd node:

    ./boot.sh &

Assuming the `FIRST_ETCD_IP_ADDRESS` variable is set to the IP address of the
first etcd node, you can deploy a second node as follows:

    ETCD_HOST=$FIRST_ETCD_IP_ADDRESS ./boot.sh &

The script runs the service on the default 2379 and 2380 ports. If you want to
create more than one node in a host, you need to specify different ports for
the additional nodes:

    ETCD_HOST=$FIRST_ETCD_IP_ADDRESS ETCD_CLIENT_PORT=2479 ETCD_PEER_PORT=2480 ./boot.sh &

You repeat the above command to add as many more nodes as you want!

## Reference

The easy-etcd deployment script accepts a number of options through environment
variables. Below is a complete list:

- `ETCD_NAME`: The name to give to the etcd node. The output of `hostname` is
  used by default.
- `ETCD_CLIENT_PORT`: The port number where etcd should listen to client
   requests. Port 2379 is used by default.
- `ETCD_PEER_PORT`: The port number where etcd should listen to requests from
  peers. port 2380 is used by default.
- `ETCD_CLUSTER_TOKEN`: The name of the cluster. The name `etcd-cluster-token`
  is used by default.
- `ETCD_LISTEN_IP_ADDRESS`: The IP address where etcd listens for requests. The
  default is to listen on all addresses (i.e. `0.0.0.0`).
- `ETCD_HOST`: The IP address of an already running node in the cluster. If
  this variable is set, the new node joins the existing cluster. If this
  variable is not set, the node starts a new cluster.
