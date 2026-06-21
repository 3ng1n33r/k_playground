#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 5 ] || [ "$#" -gt 6 ]; then
  echo "Usage: $0 <API_SERVER> <USERNAME> </path/to/user.crt> </path/to/user.key> </path/to/ca.crt> [output-file]"
  exit 1
fi

API_SERVER="$1"    # например https://cluster-endpoint:8443
USERNAME="$2"
USER_CRT="$3"
USER_KEY="$4"
CA_CRT="$5"
OUTFILE="${6:-./kubeconfig.yaml}"
CLUSTER_NAME="kubernetes"
CONTEXT_NAME="${USERNAME}@${CLUSTER_NAME}"

# Проверки файлов
for f in "$USER_CRT" "$USER_KEY" "$CA_CRT"; do
  if [ ! -f "$f" ]; then
    echo "File not found: $f" >&2
    exit 2
  fi
done

# Получаем base64 без переносов
b64() {
  if command -v base64 >/dev/null 2>&1; then
    # Try GNU-style options first
    if base64 --wrap=0 >/dev/null 2>&1 2>/dev/null; then
      base64 --wrap=0 "$1"
    elif base64 -w0 >/dev/null 2>&1 2>/dev/null; then
      base64 -w0 "$1"
    else
      # BSD/macOS: read from stdin or use -i
      base64 -i "$1" | tr -d '\n'
    fi
  else
    openssl base64 -in "$1" | tr -d '\n'
  fi
}

CA_B64="$(b64 "$CA_CRT")"
USER_CRT_B64="$(b64 "$USER_CRT")"
USER_KEY_B64="$(b64 "$USER_KEY")"

cat > "$OUTFILE" <<EOF
apiVersion: v1
kind: Config
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    server: ${API_SERVER}
    certificate-authority-data: ${CA_B64}
users:
- name: ${USERNAME}
  user:
    client-certificate-data: ${USER_CRT_B64}
    client-key-data: ${USER_KEY_B64}
contexts:
- name: ${CONTEXT_NAME}
  context:
    cluster: ${CLUSTER_NAME}
    user: ${USERNAME}
current-context: ${CONTEXT_NAME}
EOF

chmod 600 "$OUTFILE"
echo "Wrote kubeconfig to $OUTFILE"
