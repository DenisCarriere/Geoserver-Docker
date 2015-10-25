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