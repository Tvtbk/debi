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

echo 'nameserver 8.8.8.8' >> /etc/resolv.conf

echo nf!

useradd net_admin -U
echo -e "P@$$w0rd\nP@$$w0rd" passwd net_admin

echo 'net_admin ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

#1.4

apt-get install openvswitch NetworkManager-ovs -y
systemctl enable --now openvswitch


mkdir /etc/net/ifaces/ens19
mkdir /etc/net/ifaces/ens20
mkdir /etc/net/ifaces/ens21

systemctl restart network

ovs-vsctl add-br hq-sw

ovs-vsctl add-port hq-sw ens19 tag=100 # ens19 смотрит в сторону внутрь
ovs-vsctl add-port hq-sw ens20 tag=200 # virt
ovs-vsctl add-port hq-sw ens21 tag=999 # virt

ovs-vsctl add-port hq-sw vlan100 tag=100 -- set interface vlan100 type=internal
ovs-vsctl add-port hq-sw vlan200 tag=200 -- set interface vlan200 type=internal
ovs-vsctl add-port hq-sw vlan999 tag=999 -- set interface vlan999 type=internal

ip a add 192.168.100.1/26 dev vlan100
ip a add 192.168.100.65/28 dev vlan200
ip a add 192.168.100.81/29 dev vlan999

systemctl restart openvswitch

#todo: Сбрасывает адреса, нужна адресация в конфиг файлах
#systemctl restart NetworkManager

ip link set hq-sw up

# 1.6
mkdir -p /etc/net/ifaces/gre1
echo '10.10.10.1 peer 10.10.10.2' > /etc/net/ifaces/gre1/ipv4address
echo -e 'TUNLOCAL=172.16.4.2\nTUNREMOTE=172.16.5.2\nTUNTYPE=gre\nTYPE=iptun\nTUNTTL=64\nTUNMTU=1476\nTUNOPTIONS='ttl 64'\nDISABLE=no' > /etc/net/ifaces/gre1/options
echo 'default via 192.168.200.0/27' > /etc/net/ifaces/gre1/ipv4route
