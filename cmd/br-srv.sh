#!/bin/bash

hostnamectl set-hostname br-srv.au-team.irpo; exec bash

useradd sshuser -u 1010 -U
echo -e "P@ssw0rd\nP@ssw0rd" | passwd sshuser

usermod -aG wheel sshuser

echo 'sshuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
