FROM ubuntu:18.04

RUN echo $'Dpkg::Use-Pty "0";\nquiet "2";\nAPT::Install-Recommends "0";' > /etc/apt/apt.conf.d/99autopilot
RUN apt-get update
RUN apt-get install build-essential subversion bison autoconf ruby bundler zip curl
RUN apt-get upgrade && apt-get autoremove && apt-get clean

ADD . /root/
WORKDIR /root

RUN bundle install --path=vendor
