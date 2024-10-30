#!/bin/sh
# https://stackoverflow.com/a/38732187/1935918
set -e

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

/usr/local/bin/wait-for-it.sh postgres_db:5432 --timeout=60 --strict -- echo "PostgreSQL is up"

bundle exec rake db:create || true

bundle exec rake db:migrate

exec bundle exec "$@"
