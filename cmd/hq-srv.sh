#!/bin/bash

hostnamectl set-hostname hq-srv.au-team.irpo; exec bash

useradd sshuser -u 1010 -U
echo -e "P@ssw0rd\nP@ssw0rd" | passwd sshuser

usermod -aG wheel sshuser

echo 'sshuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# 1.5
# Чтобы выполнить это задание нужен доступ в инет
# Проложите временный маршрут или выполните это после настройки dhcp


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