#!/bin/bash

set -e

apt-get update
apt-get install vim mc iptables tmux -y

hostnamectl set-hostname isp.au-team.irpo; exec bash

mkdir /etc/net/ifaces/ens19
cd /etc/net/ifaces/ens19

echo 'DISABLED=no' > options
echo 'TYPE=eth' >> options
echo 'BOOTPROTO=static' >> options
echo 'CONFIG_IPV4=yes' >> options

echo 172.16.4.1/28 > ipv4address

mkdir ../ens20
mv options ../ens20/

cd ../ens20

echo 172.16.5.1/28 > ipv4address


sed -i 's/^net.ipv4.ip_forward = 0$/net.ipv4.ip_forward = 1/' /etc/net/sysctl.conf
sysctl -p /etc/net/sysctl.conf

systemctl restart network

echo nf!

iptables -t nat -A POSTROUTING -o ens18 -s 172.16.4.0/28 -j MASQUERADE
iptables -t nat -A POSTROUTING -o ens18 -s 172.16.5.0/28 -j MASQUERADE

iptables-save > /etc/sysconfig/iptables

systemctl enable --now iptables

echo nat!

# 1.11
apt-get install zoneinfo -y
timedatectl set-timezone Europe/Moscow

# Если дата не та
# timedatectl set-time "2024-01-01 00:00:00"

