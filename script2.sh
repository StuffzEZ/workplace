#!/bin/bash

set -e

echo "Stopping ALL old Guacamole containers..."
sudo docker rm -f guacamole guacamole-mysql guacamole-guacd \
  some-guacamole some-guacd some-postgres 2>/dev/null || true

echo "Removing old volumes (optional but recommended)..."
sudo docker volume rm guacamole-db guac-db 2>/dev/null || true

echo "Creating network..."
sudo docker network create guac-net 2>/dev/null || true

echo "Creating Postgres volume..."
sudo docker volume create guac-db

echo "Starting Postgres..."
sudo docker run -d \
  --name guac-postgres \
  --network guac-net \
  -e POSTGRES_DB=guacamole_db \
  -e POSTGRES_USER=guacamole_user \
  -e POSTGRES_PASSWORD=some_password \
  -v guac-db:/var/lib/postgresql/data \
  postgres

echo "Waiting for DB..."
sleep 10

echo "Initialising DB..."
sudo docker run --rm \
  --network guac-net \
  guacamole/guacamole \
  /opt/guacamole/bin/initdb.sh --postgres > initdb.sql

sudo docker cp initdb.sql guac-postgres:/initdb.sql
sudo docker exec -i guac-postgres psql -U guacamole_user -d guacamole_db -f /initdb.sql

echo "Starting guacd..."
sudo docker run -d \
  --name guac-guacd \
  --network guac-net \
  guacamole/guacd

echo "Starting Guacamole..."
sudo docker run -d \
  --name guacamole \
  --network guac-net \
  -e GUACD_HOSTNAME=guac-guacd \
  -e POSTGRES_HOSTNAME=guac-postgres \
  -e POSTGRES_DATABASE=guacamole_db \
  -e POSTGRES_USER=guacamole_user \
  -e POSTGRES_PASSWORD=some_password \
  -p 8090:8080 \
  guacamole/guacamole

echo "✅ Done: http://YOUR-IP:8090/guacamole"