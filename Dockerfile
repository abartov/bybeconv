FROM ruby:2.6

# RUN mkdir /app
# WORKDIR /app

RUN apt-get update
RUN apt-get install -y libpcap0.8-dev libyaz4-dev yaz

COPY extra/project-honeypot-0.1.3.gem ./
RUN gem install project-honeypot-0.1.3.gem

COPY Gemfile Gemfile.lock ./
RUN bundle install --binstubs

COPY . .

LABEL maintainer="Ephraim Berkovitch <ephraim.berkovitch@gmail.com>"

RUN rake db:sessions:clear
CMD rails s

# EXAMPLE
# FROM ruby:2.7.2
# RUN apt-get update && apt-get install -y --no-install-recommends build-essential libpq-dev nodejs \
#   && rm -rf /var/lib/apt/lists/*
# WORKDIR /myapp
# COPY Gemfile /myapp/Gemfile
# COPY Gemfile.lock /myapp/Gemfile.lock
# RUN gem install bundler:2.0.2 && bundle install
# COPY . /myapp