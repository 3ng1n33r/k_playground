#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC2013
for i in $(cat hostname_list);
do
  cfssl gencert -ca=etcd-ca.crt -ca-key=etcd-ca.key -config=ca-config.json -profile=peer "${i}".json | cfssljson -bare etcd-peer
  mv etcd-peer.pem "${i}"-etcd-peer.crt
  mv etcd-peer-key.pem "${i}"-etcd-peer.key

  cfssl gencert -ca=etcd-ca.crt -ca-key=etcd-ca.key -config=ca-config.json -profile=server "${i}".json | cfssljson -bare etcd-server
  mv etcd-server.pem "${i}"-etcd-server.crt
  mv etcd-server-key.pem "${i}"-etcd-server.key
done