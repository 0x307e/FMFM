FROM ruby:2.7.1-alpine
WORKDIR /app
RUN apk update && apk add git build-base
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app
CMD bundle exec ruby -Ku app.rb
