sudo docker run -d \
    -p 8080:8080 \
    -v $HOME/geoserver:/opt/geoserver/data_dir \
    -v $HOME/geoserver/data/imagery:/opt/geoserver/data_dir/imagery \
    -v $HOME/geoserver/data/vector:/opt/geoserver/data_dir/vector \
    --name geoserver \
    deniscarriere/geoserver
