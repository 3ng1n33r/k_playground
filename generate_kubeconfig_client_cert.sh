#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <username> <days>"
  exit 1
fi

USERNAME="$1"
DAYS="$2"

KEY="${USERNAME}.key"
CSR="${USERNAME}.csr"
CRT="${USERNAME}.crt"
CA_CERT="/etc/kubernetes/pki/ca.crt"
CA_KEY="/etc/kubernetes/pki/ca.key"

for f in "$CA_CERT" "$CA_KEY"; do
  if [ ! -f "$f" ]; then
    echo "Required file not found: $f" >&2
    exit 2
  fi
done

openssl genrsa -out "$KEY" 2048 \
&& openssl req -new -key "$KEY" -subj "/CN=${USERNAME}/O=Kubernetes" -out "$CSR" \
&& openssl x509 -req -in "$CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial -out "$CRT" -days "$DAYS"

openssl x509 -in "$CRT" -noout -enddate
