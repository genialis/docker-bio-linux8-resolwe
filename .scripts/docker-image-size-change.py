#!/usr/bin/env python3

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

# A script that calculates the change in size between the base and the new
# Docker image from the given image repository
#
# Requirements:
#   - docker-py (NOTE: Ensure you install the version that is compatible with
#                the Docker daemon that the script connects to)

import argparse
import sys

try:
    import docker
except ImportError:
    print("Please, install the 'docker-py' package", file=sys.stderr)
    sys.exit(1)


def human_size(size, suffix='B'):
    """Convert the given size into a human readable version. Optionally, pass
    a different suffix.

    :param size: Size
    :type size: integer or float
    :param str suffix: Suffix to put after the metric prefix
    :return: Human readable version of the given size
    :rtype: str

    """
    for unit in ['','Ki','Mi','Gi','Ti','Pi','Ei','Zi']:
        if abs(size) < 1024.0:
            return "{:3.1f} {}{}".format(size, unit, suffix)
        size /= 1024.0
    return "{:.1f} {}{}".format(size, 'Yi', suffix)


def calculate_size_change(image_repository, base_image_tag, new_image_tag):
    """Calculate change in size between the base and the new Docker
    image from the given image repository.

    :param str image_repository: The repository of the base and the new
        Docker image
    :param str base_image_tag: Tag of the base image for calculating
        the size change
    :param str new_image_tag: Tag of the new image for which to
        calcualte the size change
    :returns: Change in size in bytes
    :rtype: int

    """
    cli = docker.Client(base_url='unix://var/run/docker.sock')

    # ensure the base image is downloaded from the registry
    cli.pull(repository=image_repository, tag=base_image_tag)

    base_image = {'tag': None}
    new_image = {'tag': None}

    for img in cli.images(name=image_repository):
        for tag in img['RepoTags']:
            if tag.endswith(base_image_tag):
                base_image['tag'] = tag
                base_image['size'] = img['VirtualSize']
            if tag.endswith(new_image_tag):
                new_image['tag'] = tag
                new_image['size'] = img['VirtualSize']

    if not base_image['tag']:
        print("Base image with tag '{}' not found".format(base_image_tag),
              file=sys.stderr)
        sys.exit(1)
    if not new_image['tag']:
        print("New image with tag '{}' not found".format(new_image_tag),
              file=sys.stderr)
        sys.exit(1)

    return (new_image['size'] - base_image['size'],
            base_image['tag'], new_image['tag'])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Calculates the change in size between the base and the "
            "new Docker image from the given image repository"
    )
    parser.add_argument('docker_repo', metavar="DOCKER_REPO",
        help="Docker repository of the base and the new image of the form "
        "'[[REGISTRY/]OWNER/]REPOSITORY'")
    parser.add_argument("-bt", "--base-image-tag", default="latest",
        help="Tag of the base image for calculating the size change "
            "(default: %(default)s)")
    parser.add_argument('new_image_tag', metavar="NEW_IMAGE_TAG",
        help="Tag of the new image for which to calcualte the size change")
    args = parser.parse_args()
    size_change, base_tag, new_tag = calculate_size_change(args.docker_repo,
        args.base_image_tag, args.new_image_tag)
    print("Docker image size change between '{}' and '{}': {}".format(
        base_tag, new_tag, human_size(size_change)))
