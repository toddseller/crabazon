FROM ruby:2.6.7

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Debian 10's repositories moved to the archive
RUN echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list && apt-get update && apt-get install -y --force-yes nodejs default-mysql-client postgresql-client sqlite3 vim --no-install-recommends && rm -rf /var/lib/apt/lists/*

ARG DATABASE_URL

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN gem install bundler -v 2.2.19
RUN bundle install --without development test

COPY . /usr/src/app
RUN bundle exec rake DATABASE_URL=$DATABASE_URL assets:precompile

EXPOSE 5666

CMD ["bash"]
