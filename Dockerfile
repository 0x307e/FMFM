FROM ruby:2.5.3-alpine
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN apk update && apk add git build-base
RUN bundle install
COPY . /app
CMD bundle exec ruby -Ku bot.rb
