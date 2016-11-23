#
# Dockerfile: Installation environment for stacktile's monitor in a box
#
# This dockerfile may be used to build a complete docker image from which "monitor in a box" can be run. 
#
# to build and run the docker image: 
# cp ../requirements.txt . && docker build -f Dockerfile.mib-installer -t stacktile/mib-installer .

FROM ubuntu:16.04
MAINTAINER Dan Levin <dan@stacktile.io>


ADD requirements.txt /tmp/requirements.txt
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install libssl-dev python-pip rsync ssh git build-essential libssl-dev libffi-dev python-dev && \
    pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt

CMD git clone https://github.com/stacktile/monitorinabox.git /root/monitorinabox && cd /root/monitorinabox/examples; /bin/bash
