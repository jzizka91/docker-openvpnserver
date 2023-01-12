#!/bin/sh

set -eufo pipefail

cd /opt/openvpn

# Create user certificate
echo | ./easyrsa gen-req "$1" nopass

# Sign user certificate
echo "yes" | ./easyrsa sign-req client "$1"

mkdir -p clients/"$1"

cp ./pki/private/"$1".key clients/"$1"/client.key
cp ./pki/issued/"$1".crt clients/"$1"/client.crt
cp ./pki/ca.crt clients/"$1"/ca.crt

if [ -f "client.template" ]; then
    cp client.template clients/"$1"/client.ovpn
    cp client.template clients/"$1"/"$1"-bundle.ovpn

    cd clients/"$1"

    echo "<ca>" >>"$1"-bundle.ovpn
    cat ca.crt >>"$1"-bundle.ovpn
    echo "</ca>" >>"$1"-bundle.ovpn
    
    echo "<cert>" >>"$1"-bundle.ovpn
    cat client.crt >>"$1"-bundle.ovpn
    echo "</cert>" >>"$1"-bundle.ovpn

    echo "<key>" >>"$1"-bundle.ovpn
    cat client.key >>"$1"-bundle.ovpn
    echo "</key>" >>"$1"-bundle.ovpn
fi

printf "\n\nCertificate for "$1" created.\n\n"