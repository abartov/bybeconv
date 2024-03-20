FROM ruby:3.2.1-buster

RUN apt-get update -qq && apt-get install -y \
    curl \
    wkhtmltopdf \
    pandoc \
    yaz \
    libyaz-dev \
    libmagickwand-dev \
    libpcap-dev \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/*

WORKDIR /app

CMD bundle install && rails server -b 0.0.0.0 -P /tmp/pids/puma.pid
