#!/bin/bash

SCRIPT_PATH=$(dirname $(realpath ${0}))

source $SCRIPT_PATH/.env
readonly DOCKER_IMAGE_NAME="mysql/mysql-server:5.7.24"
readonly DOCKER_CONTAINER_NAME=$1
readonly DOCKER_MYSQL_PORT=3310
readonly DOCKER_MYSQL_VOLUME="vgdbdata"

if [ -z "$DOCKER_CONTAINER_NAME" ]; then
    echo "no user DOCKER_CONTAINER_NAME input"
    exit 1
fi

readonly CHARACTER_SET="utf8"
readonly COLLATION="utf8_general_ci"
server_system_vars_charset="--character-set-server=${CHARACTER_SET}"
server_system_vars_collation="--collation-server=${COLLATION}"
server_system_vars="${server_system_vars_charset} ${server_system_vars_collation}"
# initialize the docker mysql container instance
docker run -p $DOCKER_MYSQL_PORT:3306 -v $DOCKER_MYSQL_VOLUME:/var/lib/mysql --name $DOCKER_CONTAINER_NAME --env-file .env -d --restart=always $DOCKER_IMAGE_NAME $server_system_vars
# docker exec -it $DOCKER_CONTAINER_NAME mysql -uroot -p

sleep 5

# export db_dump
file_db_dump=$(ls -t -1 ${SCRIPT_PATH}/db_dump/* | head -1)
echo "file_db_dump=${file_db_dump}"
echo "DOCKER_CONTAINER_NAME=${DOCKER_CONTAINER_NAME}"
echo "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}"
echo "MYSQL_DATABASE=${MYSQL_DATABASE}"
docker exec -i $DOCKER_CONTAINER_NAME sh -c "exec mysql -uroot -p${MYSQL_ROOT_PASSWORD} -D${MYSQL_DATABASE}" < ${file_db_dump}
