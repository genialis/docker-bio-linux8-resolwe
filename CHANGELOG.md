# Change Log
All notable changes to the docker-bio-linux8-resolwe project will be documented
in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

### Added

- Script serving as container's entrypoint executable that enables
  dynamically setting user and group IDs of the user running in the container
  by passing them via environment variables.
- Documentation on using the image, including mounting a local directory inside
  the container and passing the host user's user and group IDs to the container
  via environment variables.
- gosu 1.9.

### Changed

- No longer set `WORKDIR` to `/home/biolinux/data`.

### Removed

- Remove creation of `~/auxiliary_data` directory since it is no longer
  necessary.
- Remove creation of `~/data` and `~/upload` directories since they will get
  automatically created when volumes are mounted from the host.

## 0.2.0 - 2016-05-17

### Added

- Script that calculates the change in size between the base and the new Docker
  image
- JBrowse 1.12.0.
- BEDOPS 2.4.15.
- GenomeTools 1.5.3.
- tabix (currently, 0.2.6).
- bedtools (currently, 2.17.0).
- p7zip-full (currently, 9.20.1).
- bamliquidator 1.2.0-0ppa1~trusty.
- MACS2 2.1.1.20160309.
- ROSE2 1.0.2.
- R packages:
  - argparse
  - chemut
  - devtools
  - RNASeqT
- Bioconductor R packages:
  - Rsamtools
  - reshape2
  - seqinr
  - stringr
  - tidyr
- vcfutils.pl from samtools package.
- cutadapt 1.9.1.
- HISAT2 2.0.3-beta.

## 0.1.0 - 2016-02-04

- Initial release.
