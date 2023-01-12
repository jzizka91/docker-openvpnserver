#!/bin/sh

set -euo pipefail

# go to /opt/openvpn dir
cd /opt/openvpn

if [ ! -f "easyrsa" ]; then
  # file easyrsa do not exist -> need to configure vpn

  # copy all easy-rsa files
  cp -r /usr/share/easy-rsa/* /opt/openvpn/.

  # create pki
  ./easyrsa init-pki

  # generate dh
  ./easyrsa gen-dh 

  # build 
  ./easyrsa build-ca nopass

  # create server certificate
  echo | ./easyrsa gen-req server nopass

  # sign server certificate
  echo "yes" | ./easyrsa sign-req server server

  # generate crl file
  ./easyrsa gen-crl
fi

# generate crl file
./easyrsa gen-crl

# start openvpn server
exec openvpn --config *.[co][ov][np][fn]