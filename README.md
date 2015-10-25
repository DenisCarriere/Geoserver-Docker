Geoserver for Docker
====================

Daemonize the Geoserver application using the `-d` flag.

```bash
$ mkdir ~/geoserver_data
$ docker run -d \
    -p 8080:8080 \
    -v ~/geoserver_data:/opt/geoserver/data_dir \
    --name geoserver \
    deniscarriere/geoserver
```