#!/bin/bash

hostnamectl set-hostname hq-srv.au-team.irpo; exec bash

useradd sshuser -u 1010 -U
echo -e "P@ssw0rd\nP@ssw0rd" | passwd sshuser

usermod -aG wheel sshuser

echo 'sshuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# 1.5
# Чтобы выполнить это задание нужен доступ в инет
# Проложите временный маршрут или выполните это после настройки dhcp

apt-get install selinux-policy -y

sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
setenforce 0

sed -i 's/^Port 22$/Port 2024' /etc/ssh/sshd_config
echo 'AllowUsers sshuser' >> /etc/ssh/sshd_config

sed -i 's/^#MaxAuthTries 6$/MaxAuthTries 2/' /etc/ssh/sshd_config

# Баннер
sed -i 's/^#Banner none$/Banner /etc/ssh-banner'

echo '**************************'
echo '* Authorized access only *' > /etc/ssh-banner
echo '**************************'

systemctl restart sshd_config

# Для проверки (запрос выполняется с клиента, он настраивается позже)
# ssh sshuser@192.168.100.2 -p 2024

apt-get install bind bind-utils -y

sed -i 's_listen-on { 127.0.0.1; }_listen-on port 53 { 127.0.0.1; 192.168.100.0/26; 192.168.100.64/28; 192.168.200.0/27; }_' /etc/bind/options.conf
sed -i 's/listen-on-v6 { ::1; }/listen-on port 53 { none; }/' /etc/bind/options.conf
sed -i 's_//allow-query { localnets; }_allow-query { any; }_' /etc/bind/options.conf
sed -i 's_//forwarders { }_forwarders { 8.8.8.8; }_' /etc/bind/options.conf
sed -i 's_//interface-interval 0;_//interface-interval 0; dnssec-validation no;_' /etc/bind/options.conf

echo -e 'zone "au-team.irpo" {\n\ttype master;\n\tfile "master/au-team.db";\n};' >> /etc/bind/local.conf

# Проверка
# named-checkconf

mkdir /etc/bind/zone/master
chown root:named /etc/bind/zone/master

# 1.11
timedatectl set-timezone Europe/Moscow
# timedatectl set-time "2024-01-01 00:00:00"
