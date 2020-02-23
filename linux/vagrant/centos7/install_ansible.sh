#!/usr/bin/env sh

yum update -y
yum install -y python3
yum install -y python3-pip
pip3 install setuptools wheel eggs
pip3 install ansible
