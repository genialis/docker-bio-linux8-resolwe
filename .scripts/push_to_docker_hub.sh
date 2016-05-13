#!/bin/bash

# Copyright 2016 The docker-bio-linux8-resolwe authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# A script to push the built images to Docker Hub

# print all lines before executing them for easier debugging
set -v

docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS

# tag builds on the "master" branch with the "latest" tag
if [[ $TRAVIS_BRANCH == "master" ]]; then
    echo "Tagging Docker image $REPO:$COMMIT as $REPO:latest"
    docker tag --force=true $REPO:$COMMIT $REPO:latest
fi

# tag builds for git tags with the corresponding tags
if [[ -n $TRAVIS_TAG ]]; then
    echo "Tagging Docker image $REPO:$COMMIT as $REPO:$TRAVIS_TAG"
    docker tag --force=true $REPO:$COMMIT $REPO:$TRAVIS_TAG
fi

docker push $REPO
