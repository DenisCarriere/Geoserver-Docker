Geoserver
=========

Set up your Nginx configuration

```conf
server {
    listen      80;
    location / {
        proxy_pass http://127.0.0.1:5000/;
    }
}

proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

Run Nginx to point to your Geoserver

```bash
docker run -d \
    -p 80:80  \
    nginx
```

Daemonize the Geoserver application using the `-d` flag.

```bash
$ mkdir ~/geoserver_data
$ docker run -d \
    -p 8080:8080 \
    -v ~/geoserver_data:/opt/geoserver/data_dir \
    --name geoserver \
    addxy/geoserver
```