#!/bin/bash

if [ -z $ENVIRONMENT ]; then ENVIRONMENT=staging; fi

bundler install
bundler exec unicorn -C /app/config/unicorn/$ENVIRONMENT.rb -E $ENVIRONMENT -D
vagrant@dropship1:/tmp/statuspage$ cat Dockerfile
FROM keyboardscience/ruby-base:0.1
MAINTAINER Kevin Phillips <kevin.phillips@omadahealth.com>

## Initial Setup
RUN apt-get update
RUN apt-get install -qy libpq-dev make automake patch
RUN useradd -r -s /bin/false rails
RUN git clone https://github.com/keyboardscience/statuspage.git /app

## Update code for branch build
RUN if [ -z $BRANCH ]; then BRANCH=master; fi; \
    cd /app \
    && git checkout $BRANCH \
    && git pull

RUN chown -R rails /app
RUN chmod a+x /app/scripts/start
RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Run the setup
USER rails
WORKDIR /app
RUN /usr/bin/bundler install --binstubs /app/bin --path /app/tmp/bundle --without development test --deployment

## If docker is run without an entrypoint...
EXPOSE 8080
CMD /app/scripts/start
