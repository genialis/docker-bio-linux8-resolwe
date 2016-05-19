docker-bio-linux8-resolwe
=========================
[![Build Status](https://travis-ci.org/genialis/docker-bio-linux8-resolwe.svg?branch=master)](https://travis-ci.org/genialis/docker-bio-linux8-resolwe)
[![ImageLayers Size](https://img.shields.io/imagelayers/image-size/resolwe/bio-linux8-resolwe/latest.svg)](https://imagelayers.io/?images=resolwe/bio-linux8-resolwe:latest)
[![ImageLayers Layers](https://img.shields.io/imagelayers/layers/resolwe/bio-linux8-resolwe/latest.svg)](https://imagelayers.io/?images=resolwe/bio-linux8-resolwe:latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/resolwe/bio-linux8-resolwe.svg)](https://hub.docker.com/r/resolwe/bio-linux8-resolwe/)

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
