# OpenVPN server

## Start OpenVPN server

The `<path-to-vpn-folder>` should contain all the necessary config files for starting the VPN server.

### Testing and provision

* Create a folder and put the `server.ovpn` and `client.template` there.
* Run the command below to provision a new OpenVPN server.

```
docker run \
   --rm -it \
   --net host \
   --name openvpn-server \
   --env EASYRSA_REQ_CN="my.vpn.example.com" \
   --env EASYRSA_BATCH="yes" \
   --cap-add=NET_ADMIN \
   --device=/dev/net/tun \
   --volume <path-to-vpn-folder>:/opt/openvpn:rw \
   ghcr.io/jzizka91/docker-openvpnserver:latest
```

### Daemonize

* Run the already configured OpenVPN server in the backgroud.
* Feel free to omit `--net host` and do `--publish 1194:1194/udp` if you do not need to modify the host networking.
For example, you need to make secure connection between the clients only.

```
docker run \
   --detach \
   --restart always \
   --net host \
   --name openvpn-server \
   --cap-add=NET_ADMIN \
   --device=/dev/net/tun \
   --volume <vpn-storage>:/opt/openvpn:rw \
   ghcr.io/jzizka91/docker-openvpnserver:latest
```

### Create users

* Certificates are stored under `<vpn-storage>/clients/<user>/`.
* File `<user>-bundle.ovpn` contains client configuration and all required certs and keys.

```
docker exec openvpn-server create-user <user>
```

### Update CRL on server

* The default `crl.pem` validity is 10 years.
* The CRL file is regenerate on every start of OpenVPN server as well as on each certificate revocation.
 
```
docker exec openvpn-server update-crl
```

### Revoke certificate

* You *do not need* to restart OpenVPN after this.

```
docker exec openvpn-server revoke-certificate <user>
```

### Client custom configuration

* Uncomment this line `;client-config-dir "/opt/openvpn/client-config"` in your `server.ovpn`.
* Create a `client-config` directory on the same level as `server.ovpn` file is.
* There you can create file with a custom configuration per each client.
For example, `echo "ifconfig-push 192.168.111.4 255.255.255.0" >client-config/myntb` to set static IP to `myntb`. Please, make sure that the `myntb` is the existing client (certificate) name.

## Iptables and routes

* Probably, you will need to masquerade (or routing) your VPN traffic.
* Modify and add this line to your /etc/rc.local

```
iptables -t nat -A POSTROUTING -s 192.168.111.0/24 ! -o tun0 -j MASQUERADE
```
