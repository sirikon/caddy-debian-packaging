#!/usr/bin/env bash

set -e

systemctl disable caddy.service
systemctl stop caddy.service
