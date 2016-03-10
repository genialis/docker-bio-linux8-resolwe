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

    echo "Preparing directory for auxiliary data..." && \
    mkdir auxiliary_data && \

    echo "Installing apt packages..." && \
    sudo apt-get update && \
    sudo apt-get -y install --no-install-recommends \
      python-pip \
      tabix \
      && \

    echo "Enabling vcfutils.pl from samtools package..." && \
    sudo ln -s /usr/share/samtools/vcfutils.pl /usr/local/bin/vcfutils.pl && \

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

    echo "Installing JBrowse..." && \
    JBROWSE_VERSION=1.12.0 && \
    JBROWSE_SHA1SUM=c74adeb9840ae5c9348e59a9054fa93cf68d0402 && \
    wget -q https://jbrowse.org/releases/JBrowse-$JBROWSE_VERSION.zip -O jbrowse.zip && \
    echo "$JBROWSE_SHA1SUM *jbrowse.zip" | sha1sum -c - && \
    unzip -q jbrowse.zip && \
    rm jbrowse.zip && \
    cd JBrowse-$JBROWSE_VERSION && \
    # patch setup.sh script to prevent formatting of example data and building
    # support for legacy tools
    sed -i '/Formatting Volvox example data .../,$d' setup.sh && \
    ./setup.sh && \
    # remove all files and directories except those we explicitly want to keep
    find . -depth -not \( \
        -path './bin*' -o \
        -path './src/perl5*' -o \
        -path './extlib/lib/perl5*' \
        -o \( -type d -not -empty \) \
    \) -delete && \
    echo "PATH=\$PATH:~/JBrowse-$JBROWSE_VERSION/bin" >> ~/.bash_profile && \
    cd .. && \

    echo "Installing BEDOPS..." && \
    BEDOPS_VERSION=2.4.15 && \
    BEDOPS_SHA1SUM=6e7ca9394f1805888cf7ccc73fbe76b25f089ad9 && \
    wget -q https://github.com/bedops/bedops/releases/download/v$BEDOPS_VERSION/bedops_linux_x86_64-v$BEDOPS_VERSION.tar.bz2 -O bedops.tar.bz2 && \
    echo "$BEDOPS_SHA1SUM *bedops.tar.bz2" | sha1sum -c - && \
    mkdir BEDOPS-$BEDOPS_VERSION && \
    tar -xf bedops.tar.bz2 --directory BEDOPS-$BEDOPS_VERSION && \
    rm bedops.tar.bz2 && \
    echo "PATH=\$PATH:~/BEDOPS-$BEDOPS_VERSION/bin" >> ~/.bash_profile && \

    echo "Installing Bioconductor R packages..." && \
    sudo Rscript --slave --no-save --no-restore-history -e " \
      package_list = c( \
        'Rsamtools', \
        'reshape2', \
        'seqinr', \
        'stringr', \
        'tidyr' \
      ); \
      source('http://www.bioconductor.org/biocLite.R'); \
      biocLite(package_list) \
    " && \

    echo "Installing Cheng Lin's Chemical Mutagenesis..." && \
    CHEMICAL_MUTAGENESIS_VERSION=9e999d4 && \
    CHEMICAL_MUTAGENESIS_SHA1SUM=c761f7f5d6fb33e670d3a16c3da37950cbb91f40 && \
    wget -q https://github.com/chenglinli/chemical_mutagenesis/archive/$CHEMICAL_MUTAGENESIS_VERSION.tar.gz -O chemical_mutagenesis.tar.gz && \
    echo "$CHEMICAL_MUTAGENESIS_SHA1SUM *chemical_mutagenesis.tar.gz" | sha1sum -c - && \
    mkdir chemical_mutagenesis-$CHEMICAL_MUTAGENESIS_VERSION && \
    tar -xf chemical_mutagenesis.tar.gz --strip-components=1 -C chemical_mutagenesis-$CHEMICAL_MUTAGENESIS_VERSION && \
    rm chemical_mutagenesis.tar.gz && \
    cd chemical_mutagenesis-$CHEMICAL_MUTAGENESIS_VERSION && \
    unzip -q -d ~/auxiliary_data/chemical_mutagenesis Reference_files.zip && \
    # remove all files expect R files which we want to keep
    find . -depth -not \( \
        -path './R/*' -o \
        \( -type d -not -empty \) \
    \) -delete && \
    # source R files in ~/.Rprofile so that they are loaded when R starts
    echo "# Cheng Lin's Chemical Mutagenesis' R scripts" >> ~/.Rprofile && \
    find `pwd` -iname "*.R" -type f -exec echo "source('{}')" >> ~/.Rprofile \; && \
    echo >> ~/.Rprofile && \
    cd .. && \

    echo "Preparing directories..." && \
    mkdir upload && \
    mkdir data && \

    echo "Cleaning up..." && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

WORKDIR /home/biolinux/data
