#!/usr/bin/env bash
# exit on error
set -o errexit

export RAILS_ENV=production  # 明示的に設定
bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
# bundle exec rake db:migrate
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:migrate:reset
