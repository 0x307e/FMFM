FROM ruby:2.6.4-alpine
WORKDIR /app
RUN apk update && apk add git build-base
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app
CMD bundle exec ruby -Ku app.rb
