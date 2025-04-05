#!/bin/bash

hostnamectl set-hostname br-rtr.au-team.irpo; exec bash

cd /etc/net/ifaces/ens18

echo 'DISABLED=no' > options
echo 'TYPE=eth' >> options
echo 'BOOTPROTO=static' >> options
echo 'CONFIG_IPV4=yes' >> options

echo 172.16.5.2/28 > ipv4address
echo 'default via 172.16.5.1' > ipv4route

sed -i 's/^net.ipv4.ip_forward = 0$/net.ipv4.ip_forward = 1/' /etc/net/sysctl.conf
sysctl -p /etc/net/sysctl.conf

systemctl restart network

echo 'nameserver 8.8.8.8' >> /etc/resolv.conf

echo nf!

useradd net_admin -U
echo -e "P@$$w0rd\nP@$$w0rd" passwd net_admin

echo 'net_admin ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# 1.6
mkdir -p /etc/net/ifaces/gre1
echo '10.10.10.2 peer 10.10.10.1' > /etc/net/ifaces/gre1/ipv4address
echo -e 'TUNLOCAL=172.16.5.2\nTUNREMOTE=172.16.4.2\nTUNTYPE=gre\nTYPE=iptun\nTUNTTL=64\nTUNMTU=1476\nTUNOPTIONS='ttl 64'\nDISABLE=no' > /etc/net/ifaces/gre1/options
echo 'default via 192.168.100.0/26' > /etc/net/ifaces/gre1/ipv4route