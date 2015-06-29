FROM keyboardscience/ruby-base:0.1

RUN apt-get update
RUN apt-get install -qy libpq-dev
RUN useradd -r -s /bin/false rails
RUN git clone https://github.com/keyboardscience/statuspage.git /app

CMD if [ -z $BRANCH ]; then BRANCH=master; fi; \
    cd /app \
    && git checkout $BRANCH \
    && git pull

ADD scripts/setup /setup
CMD su rails -c /setup

EXPOSE 8080
USER rails
CMD /start
