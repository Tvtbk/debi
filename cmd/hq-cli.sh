#!/bin/bash

set -e

hostnamectl set-hostname hq-cli.au-team.irpo; exec bash

# 1.11
timedatectl set-timezone Europe/Moscow
# timedatectl set-time "2024-01-01 00:00:00"
