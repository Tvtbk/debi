#!/bin/bash

hostnamectl set-hostname hq-rtr.au-team.irpo; exec bash

cd /etc/net/ifaces/ens18

echo 'DISABLED=no' > options
echo 'TYPE=eth' >> options
echo 'BOOTPROTO=static' >> options
echo 'CONFIG_IPV4=yes' >> options

echo 172.16.4.2/28 > ipv4address
echo 'default via 172.16.4.1' > ipv4route

sed -i 's/^net.ipv4.ip_forward = 0$/net.ipv4.ip_forward = 1/' /etc/net/sysctl.conf
sysctl -p /etc/net/sysctl.conf

systemctl restart network

echo nf!

useradd net_admin -U
echo -e "P@$$w0rd\nP@$$w0rd" passwd net_admin

echo 'net_admin ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
