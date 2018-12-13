docker-bio-linux8-resolwe
=========================
[![Build Status](https://travis-ci.org/genialis/docker-bio-linux8-resolwe.svg?branch=master)](https://travis-ci.org/genialis/docker-bio-linux8-resolwe)
[![Docker Pulls](https://img.shields.io/docker/pulls/resolwe/bio-linux8-resolwe.svg?maxAge=2592000)](https://hub.docker.com/r/resolwe/bio-linux8-resolwe/)
<!---
Temporarily disable ImageLayers badges until Shields resolves the issue:
https://github.com/badges/shields/issues/712
[![ImageLayers Size](https://img.shields.io/imagelayers/image-size/resolwe/bio-linux8-resolwe/latest.svg?maxAge=2592000)](https://imagelayers.io/?images=resolwe/bio-linux8-resolwe:latest)
[![ImageLayers Layers](https://img.shields.io/imagelayers/layers/resolwe/bio-linux8-resolwe/latest.svg?maxAge=2592000)](https://imagelayers.io/?images=resolwe/bio-linux8-resolwe:latest)
-->

UPDATE (2018-12-13)
-------------------

This Docker image and its corresponding Docker Hub images,
[resolwe/bio-linux8](https://hub.docker.com/r/resolwe/bio-linux8/),
[resolwe/bio-linux8-resolwe](
    https://hub.docker.com/r/resolwe/bio-linux8-resolwe/),
[resolwe/bio-linux8-resolwe-preview](
    https://hub.docker.com/r/resolwe/bio-linux8-resolwe-preview/),
[resolwe/bio-linux8-ugly](
    https://hub.docker.com/r/resolwe/bio-linux8-ugly/),
have been superseeded by [Resolwe's](https://hub.docker.com/u/resolwe/) and
[Resolwe Bioinformatics'](https://hub.docker.com/u/resolwebio/) Docker Hub
repositories which contain a set of smaller, modular Docker images.

Therefore, this repository along with its Docker Hub images will be
**deleted on Mar 13, 2019**.

<strike>

Containerized version of [Bio-Linux 8](http://environmentalomics.org/bio-linux/)
tailored for [Resolwe](https://github.com/genialis/resolwe).

Usage
-----

To start an interactive session in the container, use:

```
docker run -it resolwe/bio-linux8-resolwe
```

To instruct Docker to automatically remove the container when it exits, pass
the `--rm` option to the command:

```
docker run -it --rm resolwe/bio-linux8-resolwe
```

To mount a local directory inside the container, pass the
`-v <host-path>:<container-path>` option to the command, e.g.:

```
docker run -it --rm -v $PWD/data_dir:/home/biolinux/data resolwe/bio-linux8-resolwe
```

*NOTE: Use absolute paths to specify `<host-path>` and `<container-path>`.*

However, if the user and group IDs of the user on the host don't match the user
and group IDs of the `biolinux` user used inside the container, this won't
work:

```
$ docker run -it --rm -v $PWD/data_dir:/home/biolinux/data resolwe/bio-linux8-resolwe \
  touch /home/biolinux/data/foo
touch: cannot touch '/home/biolinux/data/foo': Permission denied
```

To solve this problem, pass the host user's user and group IDs to the container
as `HOST_UID` and `HOST_GID` environment variables and the image's entrypoint
script will change the `biolinux` user's user and group IDs automatically:

```
$ docker run -it --rm -v $PWD/data_dir:/home/biolinux/data \
  -e HOST_UID=$(id -u) -e HOST_GID=$(id -g) resolwe/bio-linux8-resolwe \
  touch /home/biolinux/data/foo
$ ls data_dir | grep foo
foo
```
</strike>
