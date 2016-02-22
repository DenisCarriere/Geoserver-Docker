#!/bin/bash
# Build Docker Geoserver
sudo docker stop geoserver
sudo docker build -t deniscarriere/geoserver .
