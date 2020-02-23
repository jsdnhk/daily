#!/usr/bin/env sh

# create and push the new tag to the git remote

readonly SCRIPT_PATH=$(dirname $(realpath ${0}))
cd $SCRIPT_PATH/..

readonly DOCKER_IMAGE_TAG=$(xpath -n -e '/project/version[1]/text()' ./pom.xml)

# Input the commit message
commit_msg=""
read -p "Enter the commit message: " commit_msg

# Commit the src. change
cd ../
git checkout master
git add .
git commit -m "${commit_msg}"
git push

# Delete and recreate the tag locally
tagname="v${DOCKER_IMAGE_TAG}"
git tag -d ${tagname}
git tag ${tagname}

# Delete and recreate the tag remotely
git push origin ":${tagname}"  # deletes original remote tag
git push origin "${tagname}" # creates new remote tag

# Update local repository with the updated tag
git fetch --tags