#!/bin/sh

set -eufo pipefail

cd /opt/openvpn

# Update CRL
./easyrsa gen-crl