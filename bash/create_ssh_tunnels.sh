#!/usr/bin/env bash

# create the ssh tunnels

set -eu

readonly ssh_bind_port_local="bind-port"
readonly ssh_target_host_port="target-host-port"
readonly ssh_login_host="remote-host"
readonly ssh_login_port="remote-port"
readonly ssh_login_user="remote-user"
readonly ssh_config_option="-oServerAliveInterval=180 -oServerAliveCountMax=3"


ssh -f ${ssh_config_option} -L ${ssh_bind_port_local}:${ssh_target_host_port} -p ${ssh_login_port} ${ssh_login_user}@${ssh_login_server} -N
echo "The ssh tunnels are built successfully."
exit 0

# observe the status of the ssh tunnels ports
# netstat -nltp | grep -E "^tcp\b" | grep "\|port1\|port2\|port3\|port4"
