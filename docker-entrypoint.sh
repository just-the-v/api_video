#!/bin/sh
set -x
rm -f /tmp/rails.pid
rails db:create
rails db:migrate
rails server -b 0.0.0.0 --pid /tmp/rails.pid
