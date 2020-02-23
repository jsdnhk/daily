#!/usr/bin/env bash

# build the java application docker images and push to the remote registry

readonly SCRIPT_PATH=$(dirname $(realpath ${0}))
cd $SCRIPT_PATH/..

readonly DOCKER_IMAGE_PREFIX=$(xpath -n -e '/project/properties/docker.image.prefix[1]/text()' ./pom.xml)
readonly DOCKER_IMAGE_ARTIFACT_ID=$(xpath -n -e '/project/artifactId[1]/text()' ./pom.xml)
readonly DOCKER_IMAGE_NAME="${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_ARTIFACT_ID}"
readonly DOCKER_IMAGE_TAG=$(xpath -n -e '/project/version[1]/text()' ./pom.xml)
readonly DOCKER_CONTAINER_NAME=$(xpath -n -e '/project/properties/docker.container.name[1]/text()' ./pom.xml)
readonly SPRING_PROFILES_ACTIVE=$(xpath -n -e '/project/properties/spring.profiles.active[1]/text()' ./pom.xml)

# package the new src to jar file
mvn clean package -Dmaven.test.skip=true -P$SPRING_PROFILES_ACTIVE

# Build up the docker image
docker inspect "$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG" &> /dev/null
if [ $? -eq 0 ]; then
  docker rmi -f "$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG"
fi
docker build -t "$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG" .  --no-cache

# Push the change to the private repository
private_docker_repo_addr=""
if [ $SPRING_PROFILES_ACTIVE = "dev" ]; then
  private_docker_repo_addr="192.168.1.29:5000"
  docker rmi --force "${private_docker_repo_addr}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
  docker tag "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}" "${private_docker_repo_addr}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
  docker push "${private_docker_repo_addr}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
fi