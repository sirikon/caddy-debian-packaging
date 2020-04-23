#!/usr/bin/env bash

set -e

getent group caddy &>/dev/null || groupadd --system caddy
id -u caddy &>/dev/null || useradd --system \
    --gid caddy \
    --home-dir /etc/caddy \
    --shell /usr/sbin/nologin \
    --comment "Caddy Server" \
    caddy
chown -R caddy:caddy /etc/caddy
systemctl enable caddy.service
systemctl start caddy.service
