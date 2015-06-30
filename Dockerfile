FROM keyboardscience/ruby-base:0.1
MAINTAINER Kevin Phillips <kevin.phillips@omadahealth.com>

## Initial Setup
RUN apt-get update
RUN apt-get install -qy libpq-dev make automake
RUN useradd -r -s /bin/false rails
RUN git clone https://github.com/keyboardscience/statuspage.git /app

## Update code for branch build
RUN if [ -z $BRANCH ]; then BRANCH=master; fi; \
    cd /app \
    && git checkout $BRANCH \
    && git pull

## Copy scripts
ADD scripts/setup /setup
ADD scripts/start /start
ADD config/systemd/statuspage.service /lib/systemd/system/statuspage.service
ADD config/systemd/statuspage.socket /lib/systemd/system/statuspage.socket

## Run the setup
RUN su rails -c /setup

## Cleanup after ourselves
RUN apt-get purge -y make automake && \
    apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN systemctl daemon-reload

## If docker is run without an entrypoint...
EXPOSE 8080
USER rails
WORKDIR /app
CMD /start
