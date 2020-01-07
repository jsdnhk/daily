#!/bin/bash

SCRIPT_PATH=$(dirname $(realpath ${0}))
cd $SCRIPT_PATH

readonly CONTAINER_NAME='jupyter_notebook'
readonly CONTAINER_DATA_DIR="${SCRIPT_PATH}/${CONTAINER_NAME}_data"
mkdir ${CONTAINER_DATA_DIR}
sudo chmod 700 ${CONTAINER_DATA_DIR}
sudo chown root:root ${CONTAINER_DATA_DIR}

docker stop ${CONTAINER_NAME}
docker rm -f ${CONTAINER_NAME}

docker run -d --restart=always -p 10000:8888 \
-e JUPYTER_ENABLE_LAB=yes \
-v ${CONTAINER_DATA_DIR}:/home/jovyan/work \
--name ${CONTAINER_NAME} \
jupyter_notebook:latest
