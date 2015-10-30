Geoserver on Docker
===================

Geoserver Dockerfile with GDAL bindings which include:

- ECW
- MrSID
- JP2K


Getting Started
---------------

Run your geoserver on port 8080 and mount your `data_dir`.

```bash
$ mkdir ~/geoserver_data
$ docker run -d \
    -p 8080:8080 \
    -v ~/geoserver_data:/opt/geoserver/data_dir \
    --name geoserver \
    deniscarriere/geoserver
```

GDAL
----

How imagery metadata using **GDALInfo** on a MrSid file.

```bash
docker run -t -i -v /data:/data -v /www:/www geodata/gdal /bin/bash
```

How to create a TMS using **GDAL2Tiles.py** on a MrSid file.

```bash
gdal2tiles.py -z 0-13 Brockville.sid /www/brockville/
```

- `-z` Zoom Levels
- `-s` Source input projection
- `input` Input files
- `output` Output folder

Nginx
-----

Set up your Nginx configuration in `/etc/nginx/sites-available/geoserver`.

```conf
server {
    listen  80;
    server_name  example.com www.example.com;
    location / {
        proxy_pass  http://127.0.0.1:8080/;
    }
}

proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```
