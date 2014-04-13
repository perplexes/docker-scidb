# SciDB 14.3.0.7383
#
# VERSION 1.0
#
# TODO: Install P4/shim

FROM stackbrew/ubuntu:saucy
MAINTAINER Colin Curtin, colin.t.curtin@gmail.com

# RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main universe" > /etc/apt/sources.list
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ saucy-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes curl
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y sshpass openssh-server whois git postgresql-9.3 pgadmin3

RUN useradd -m scidb && \
    PASSWD=`mkpasswd --method=sha-512 --salt=xGzGXYRE scidb` && \
    sed -i 's,scidb:,scidb:'"$PASSWD"',' /etc/shadow && \
    sed -i 's,root:,root:'"$PASSWD"',' /etc/shadow && \
    sed -i 's,postgres:,postgres:'"$PASSWD"',' /etc/shadow

# SciDB wants a disk?
RUN mkdir /home/scidb/disk0
RUN chown scidb:scidb /home/scidb/disk0

RUN git clone https://github.com/Paradigm4/deployment.git

# Get your configration here: http://htmlpreview.github.io/?https://raw.github.com/Paradigm4/configurator/master/config.14.3.html
ADD scidb_config /root/scidb_config
RUN sed -i s/HOSTNAME/$HOSTNAME/g /root/scidb_config

ENV USER root
ENV HOME /root

RUN cd deployment/14.3 && echo "y" | ./cluster_install.sh -s 255.255.255.0/32 /root/scidb_config