#!/bin/sh

set -eufo pipefail

cd /opt/openvpn

# Revoke certificate
echo "yes" | ./easyrsa revoke "$1"

# Generate CRL
./easyrsa gen-crl