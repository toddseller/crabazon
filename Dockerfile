FROM ruby:3.4.12

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y --force-yes nodejs default-mysql-client postgresql-client sqlite3 vim --no-install-recommends && rm -rf /var/lib/apt/lists/*

ARG DATABASE_URL

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

ENV BUNDLE_WITHOUT="development test"
RUN bundle install

COPY . /usr/src/app
RUN bundle exec rake DATABASE_URL=$DATABASE_URL assets:precompile

EXPOSE 5666

CMD ["bash"]
