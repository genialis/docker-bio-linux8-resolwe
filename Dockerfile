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

COPY docker-entrypoint.sh /

# XXX: Remove this step after updating resolwe-runtime-utils
COPY re-import.sh re-import.sh
# XXX: Remove this step after updating resolwe-runtime-utils
COPY curlprogress.py /usr/local/bin/

RUN export DEBIAN_FRONTEND=noninteractive && \

    echo "System information:" && \
    export NPROC=$(nproc) && \
    echo "  - $NPROC processing units available" && \
    echo "  - $(free -h | grep Mem | awk '{print $2}') of memory available" && \

    echo "Adding Bradner Lab's pipeline PPA..." && \
    sudo add-apt-repository -y ppa:bradner-computation/pipeline && \

    echo "Installing apt packages..." && \
    sudo apt-get update && \
    sudo apt-get -y install --no-install-recommends \
      bamliquidator=1.2.0-0ppa1~trusty \
      bedtools \
      p7zip-full \
      python-pip \
      r-cran-devtools \
      # r-cran-devtools requires a newer version of r-cran-memoise
      r-cran-memoise \
      tabix \
      && \

    echo "Installing gosu..." && \
    GOSU_VERSION=1.9 && \
    sudo wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" && \
    # check gosu authenticity using gnupg
    sudo wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    sudo rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    # make gosu executable
    sudo chmod +x /usr/local/bin/gosu && \
    sudo gosu nobody true && \

    echo "Enabling vcfutils.pl from samtools package..." && \
    sudo ln -s /usr/share/samtools/vcfutils.pl /usr/local/bin/vcfutils.pl && \

    echo "Installing resolwe-runtime-utils..." && \
    sudo pip install resolwe-runtime-utils==1.0.0 && \
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

    echo "Installing MACS2..." && \
    sudo pip install MACS2==2.1.1.20160309 && \

    echo "Installing ROSE2..." && \
    sudo pip install rose2==1.0.2 && \

    echo "Installing cutadapt..." && \
    sudo pip install cutadapt==1.9.1 && \

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

    echo "Installing GenomeTools..." && \
    GENOMETOOLS_VERSION=1.5.3 && \
    GENOMETOOLS_SHA1SUM=a0a3a18acf68728ffb177a54c81ddb3295aa325d && \
    wget -q https://github.com/genometools/genometools/archive/v$GENOMETOOLS_VERSION.tar.gz -O genometools.tar.gz && \
    echo "$GENOMETOOLS_SHA1SUM *genometools.tar.gz" | sha1sum -c - && \
    mkdir genometools-$GENOMETOOLS_VERSION && \
    tar -xf genometools.tar.gz --directory genometools-$GENOMETOOLS_VERSION --strip-components=1 && \
    rm genometools.tar.gz && \
    cd genometools-$GENOMETOOLS_VERSION && \
    make 64bit=yes cairo=no -j $NPROC && \
    sudo make 64bit=yes cairo=no install && \
    cd .. && \
    rm -rf genometools-$GENOMETOOLS_VERSION && \

    echo "Installing HISAT2..." && \
    HISAT_VERSION=2.0.3-beta && \
    HISAT_SHA1SUM=d7a06ddb4d263f47140871de3ddd6ae5fbbf9d14 && \
    wget -q ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/downloads/hisat2-$HISAT_VERSION-Linux_x86_64.zip -O hisat2.zip && \
    echo "$HISAT_SHA1SUM *hisat2.zip" | sha1sum -c - && \
    unzip -q hisat2.zip && \
    rm hisat2.zip && \
    # remove debugging files, documentation and examples
    rm hisat2-$HISAT_VERSION/*-debug && \
    rm -r hisat2-$HISAT_VERSION/doc && \
    rm -r hisat2-$HISAT_VERSION/example && \
    echo "PATH=\$PATH:~/hisat2-$HISAT_VERSION" >> ~/.bash_profile && \

    echo "Installing R packages..." && \
    sudo Rscript --slave --no-save --no-restore-history -e " \
      package_list = c( \
        'argparse' \
      ); \
      install.packages(package_list) \
    " && \

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

    echo "Installing R packages from GitHub..." && \
    sudo Rscript --slave --no-save --no-restore-history -e " \
      library(devtools); \
      install_github('jkokosar/chemut'); \
      install_github('jkokosar/RNASeqT') \
    " && \

    echo "Cleaning up..." && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# XXX: Remove this after converting the whole Dockerfile to run as root
USER root

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/bin/bash"]
