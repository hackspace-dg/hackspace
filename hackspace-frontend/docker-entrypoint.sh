#!/bin/sh
set -eu

PORT="${PORT:-8080}"
BACKEND_URL="${BACKEND_URL:?BACKEND_URL is required}"
BACKEND_URL="${BACKEND_URL%/}"
BACKEND_HOST="${BACKEND_URL#https://}"
BACKEND_HOST="${BACKEND_HOST#http://}"
BACKEND_HOST="${BACKEND_HOST%%/*}"

export PORT BACKEND_URL BACKEND_HOST

envsubst '${PORT} ${BACKEND_URL} ${BACKEND_HOST}' \
  < /etc/nginx/templates/default.conf.template \
  > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
