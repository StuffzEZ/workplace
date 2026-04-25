#!/bin/bash

echo "Installing Docker..."
sudo apt update
sudo apt install -y docker.io

sudo systemctl enable docker
sudo systemctl start docker

echo "Starting Guacamole (all-in-one)..."
sudo docker run -d \
  --name guacamole \
  -p 8080:8080 \
  oznu/guacamole

echo "Done!"
echo "Open: http://YOUR-IP:8080"
echo "Login: guacadmin / guacadmin"