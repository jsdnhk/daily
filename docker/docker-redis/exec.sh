#!/bin/bash
#build redis docker image + exec. the docker container

DOCKER_IMAGE_NAME=$1
DOCKER_CONTAINER_NAME=$2
if [ $# -ne 2 ]; then
    echo "not correct args. no. to input, should be executed like \"./exec.sh [DOCKER_IMAGE_NAME] [DOCKER_CONTAINER_NAME]\""
    exit 1
elif [ -z "$1" ]; then
    echo "no DOCKER_IMAGE_NAME input"
    exit 1
elif [ -z "$2" ]; then
    echo "no DOCKER_CONTAINER_NAME input"
    exit 1
fi

docker build  -t $1 .   #build up the docker image
mkdir $PWD/data &> /dev/null    #create the folder in host to store the data from Docker
docker run -p 6379:6379 -v $PWD/data:/data --name "$2" -d --restart=always $1:latest    #run the redis docker image(127.0.0.1:6379) in bg
docker exec -it $2 redis-cli    #execute the redis cli inside container
