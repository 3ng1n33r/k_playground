#!/bin/bash

cfssl gencert -ca=etcd-ca.crt -ca-key=etcd-ca.key -config=ca-config.json -profile=client etcd-client.json | cfssljson -bare apiserver-etcd-client
mv apiserver-etcd-client.pem apiserver-etcd-client.crt
mv apiserver-etcd-client-key.pem apiserver-etcd-client.key
rm -f -- *csr