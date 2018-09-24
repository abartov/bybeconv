FROM ruby:2.5.1

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