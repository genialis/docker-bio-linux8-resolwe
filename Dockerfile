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

# Dockerfile to build a Resolwe-tailored version of Bio-Linux 8

FROM resolwe/bio-linux8

MAINTAINER Genialis <dev-team@genialis.com>

# XXX: Remove this step after updating resolwe-runtime-utils
ADD re-import.sh re-import.sh
# XXX: Remove this step after updating resolwe-runtime-utils
ADD curlprogress.py /usr/local/bin/curlprogress.py

RUN export DEBIAN_FRONTEND=noninteractive && \

    echo "Installing pip..." && \
    sudo apt-get update && \
    sudo apt-get -y install --no-install-recommends python-pip && \

    echo "Installing resolwe-runtime-utils..." && \
    sudo pip install resolwe-runtime-utils==0.2.0 && \
    # XXX: Remove this hack after updating resolwe-runtime-utils
    echo 're-checkrc() { _re-checkrc $? "$@"; }' >> ~/.bash_profile && \
    # XXX: Remove this hack after updating resolwe-runtime-utils
    cat re-import.sh >> ~/.bash_profile && \
    rm re-import.sh && \
    # XXX: Remove this after updating resolwe-runtime-utils
    sudo chmod +x /usr/local/bin/curlprogress.py && \
    # TODO: Remove this after removing re-require from processes in resolwe-bio
    echo 're-require() { echo "WARNING: Using re-require is deprecated"; }' >> ~/.bash_profile && \
    # This is a convenience that makes 're-checkrc' and 're-import' functions
    # also available when starting the container with 'docker run -it'
    # XXX: Remove this after updating resolwe-runtime-utils
    echo "[[ -f ~/.bash_profile ]] && source ~/.bash_profile" >> ~/.bashrc && \

    echo "Preparing directories..." && \
    mkdir upload && \
    mkdir data && \

    echo "Cleaning up..." && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

WORKDIR /home/biolinux/data
