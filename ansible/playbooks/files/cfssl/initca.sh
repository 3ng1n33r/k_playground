#!/usr/bin/env bash

# etcd ca
mkdir -p etcd
cfssl gencert -initca -cn=etcd-ca ca-csr.json | cfssljson -bare etcd-ca -
mv etcd-ca.pem etcd-ca.crt
mv etcd-ca-key.pem etcd-ca.key

#rm -f -- *.csr