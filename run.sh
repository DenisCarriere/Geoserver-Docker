#!/bin/bash
# Stop existing services
# Create Data folders
mkdir -p $HOME/geoserver/data/imagery \
	 $HOME/geoserver/data/vector \

# Start Docker Geoserver
sudo docker run -d \
    -p 8080:8080 \
    -v $HOME/geoserver/data/imagery:/opt/geoserver/data_dir/imagery \
    -v $HOME/geoserver/data/vector:/opt/geoserver/data_dir/vector \
    --name geoserver \
    deniscarriere/geoserver
