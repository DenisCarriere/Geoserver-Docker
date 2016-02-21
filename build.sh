mkdir -p $HOME/geoserver/data/imagery \
	 $HOME/geoserver/data/vector \
	 $HOME/geoserver

sudo docker build -t deniscarriere/geoserver .
