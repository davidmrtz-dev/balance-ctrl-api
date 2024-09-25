FROM ruby:3.2.0-slim-buster

WORKDIR app

RUN apt update && apt install ruby-dev -y build-essential libpq-dev

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
ARG API_VERSION
ENV API_VERSION $API_VERSION
RUN gem install bundler
RUN bundle install
COPY . .

RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

# Let's check what's going on here before we reenable gunicorn
# RUN pipenv install gunicorn
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
