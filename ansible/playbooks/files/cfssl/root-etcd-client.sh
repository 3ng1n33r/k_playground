#!/bin/bash

cfssl gencert -ca=etcd-ca.crt -ca-key=etcd-ca.key -config=ca-config.json -profile=client root-etcd-client.json | cfssljson -bare root-etcd-client
mv root-etcd-client.pem root-etcd-client.crt
mv root-etcd-client-key.pem root-etcd-client.key
rm -f -- *csr
openssl verify -CAfile etcd-ca.crt root-etcd-client.crt
openssl x509 -in root-etcd-client.crt -noout -pubkey | openssl sha256
openssl ec -in root-etcd-client.key -pubout | openssl sha256