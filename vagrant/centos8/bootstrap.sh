#!/usr/bin/env sh

dnf update -y
dnf install -y python3
dnf install -y python3-pip
pip3 install setuptools wheel eggs
pip3 install ansible
dnf install -y podman docker buildah
