#!/bin/bash

cfssl gencert -ca=etcd-ca.crt -ca-key=etcd-ca.key -config=ca-config.json -profile=client etcd-healthcheck-client-csr.json | cfssljson -bare etcd-healthcheck-client

mv etcd-healthcheck-client.pem healthcheck-client.crt
mv etcd-healthcheck-client-key.pem healthcheck-client.key
rm -f -- *csr

#kubectl -n monitoring create secret generic etcd-client-cert --from-file=etcd-ca.crt --from-file=healthcheck-client.crt --from-file=healthcheck-client.key