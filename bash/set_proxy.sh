#!/usr/bin/env bash

# set/unset proxy data on the current shell env.
# usage: source ./set_proxy.sh [setp/sets/unset]

function setproxy() {
    export {http,https,ftp,socks}_proxy="http://$1:$2"
    export no_proxy="localhost"
    export JAVA_OPTS="-DproxyHost=$1 -DproxyPort=$2"
    export MAVEN_OPTS="-DsocksProxyHost=$1 -DsocksProxyPort=$2"
}

function unsetproxy() {
    unset {http,https,ftp,socks,no}_proxy
    unset JAVA_OPTS
    unset MAVEN_OPTS
}

prod_url=''
prod_port=''
staging_url=''
staging_port=''

if [ $1 = 'setp' ]; then
    setproxy $prod_url $prod_port
    echo "The proxy is set [production]!"
elif [ $1 = 'sets' ]; then
    setproxy $staging_url $staging_port
    echo "The proxy is set [staging]!"
elif [ $1 = 'unset' ]; then
    unsetproxy
    echo "The proxy is earsed!"
else
    echo "Invalid input for setting proxy[set/unset]"
fi
