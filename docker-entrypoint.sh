#!/bin/bash

# Copyright 2016, 2017 The docker-bio-linux8-resolwe authors.
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

# A script serving as container's entrypoint executable that enables
# dynamically setting user and group IDs of the user running in the container
# by passing them via environment variables.

# exit immediately if a command exits with a non-zero status
set -e

if [[ -v HOST_UID ]]; then
    ORIG_HOME=$(getent passwd biolinux | cut -d : -f 6)
    TEMP_HOME=$(mktemp --directory)
    # change biolinux's home directory to avoid chown-ing all its files
    usermod biolinux --home $TEMP_HOME
    # change biolinux user's ID to the given value (allow a non-unique value)
    usermod --uid $HOST_UID --non-unique biolinux
    # revert biolinux's home directory to its original value
    usermod biolinux --home $ORIG_HOME
    # manually change user for hidden files in the home directory
    chown $HOST_UID $ORIG_HOME/.*
fi
if [[ -v HOST_GID ]]; then
    # change biolinux group's ID to the given value (allow a non-unique value)
    groupmod --gid $HOST_GID --non-unique biolinux
    # manually change group for hidden files in the home directory
    chown :$HOST_GID $ORIG_HOME/.*
fi

# switch to user biolinux and execute the given command
# NOTES:
#  - the exec Bash command is used so that the given command becomes the
#    container's PID 1
#  - the gosu command (https://github.com/tianon/gosu) ensures that once the
#    user/group is processed, it switches to that user and execs the given
#    command. gosu itself is no longer resident or involved in the command's
#    lifecycle at all.
exec gosu biolinux "$@"
