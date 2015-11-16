Geoserver on Docker
===================

Geoserver Dockerfile with GDAL bindings which include:

- ECW
- MrSID
- JP2K

TMS REST Points
---------------

### Brockville Airport

**JOSM**

`tms[22]:http://{switch:a,b,c}.tile.addxy.com/brockville/{zoom}/{x}/{y}.png?api_key=123`

**iD Editor**

`http://{switch:a,b,c}.tile.addxy.com/brockville/{zoom}/{x}/{y}.png?api_key=123`

Getting Started
---------------

Download some data from your Amazon S3 buckets

```bash
$ mkdir -p /data/imagery
$ cd /data/imagery
$ wget https://s3-us-west-2.amazonaws.com/<FILE PATH>.sid
$ wget https://s3-us-west-2.amazonaws.com/<FILE PATH>.ecw

$ mkdir -p /data/vector
$ cd /data/vector
$ wget https://s3-us-west-2.amazonaws.com/<FILE PATH>.geojson
```

Run your geoserver on port 8080 and mount to your `data_dir`.

```bash
$ mkdir /data/geoserver
$ docker run -d \
    -p 8080:8080 \
    -v /data/geoserver:/opt/geoserver/data_dir \
    -v /data/imagery:/opt/geoserver/data_dir/imagery \
    -v /data/vector:/opt/geoserver/data_dir/vector \
    --name geoserver \
    deniscarriere/geoserver
```

GDAL
----

How imagery metadata using **GDALInfo** on a MrSid file.

```bash
cd /usr/local/bin
wget https://github.com/GitHubRGI/geopackage-python/raw/master/Packaging/tiles2gpkg_parallel.py
wget https://github.com/GitHubRGI/geopackage-python/raw/master/Tiling/gdal2tiles_parallel.py
docker run -t -i -v /data:/data -v /usr/local/bin/:/usr/local/bin/ geodata/gdal /bin/bash
```

How to create a TMS using **GDAL2Tiles.py** on a MrSid file.

```bash
gdal2tiles.py --zoom 0-13 --srcnodata 0,0,0 Brockville.sid /www/brockville/
```

- `-z` Zoom Levels
- `-s` Source input projection
- `input` Input files
- `output` Output folder

How to use the tiling script, gdal2tiles_parallel.py

- https://github.com/GitHubRGI/geopackage-python


TMS Resolution
--------------

| Zoom Level |     Scale      | Pixel Resolution |
|:-----------|:---------------|:----------------:|
|  22        |  1:125         |  3.5 cm          |
|  21        |  1:250         |  7 cm            |
|  20        |  1:500         |  15 cm           |
|  19        |  1:1,000       |  30 cm           |
|  18        |  1:2,000       |  60 cm           |
|  17        |  1:4,000       |  1.2 m           |
|  16        |  1:8,000       |  2.4 m           |
|  14        |  1:35,000      |  10 m            |
|  11        |  1:250,000     |  76 m            |
|  10        |  1:500,000     |  153 m           |
|  9         |  1:1 Million   |  305 m           |
|  7         |  1:4 Million   |  1.2 km          |

Amazon S3
---------

### Permissions

```json
{
  "Version": "2012-10-17",
  "Id": "S3PolicyId1",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::pacgeo/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "52.24.20.105/24"
        }
      }
    }
  ]
}
```

Nginx
-----

Set up your Nginx configuration in `/etc/nginx/sites-available/geoserver`.

```conf
server {
    listen  80;
    server_name  addxy.com www.addxy.com;
    location / {
        proxy_pass  http://127.0.0.1:8080/;
    }
}

server {
    listen  80;
    server_name  
        tile.addxy.com www.tile.addxy.com
        a.tile.addxy.com www.a.tile.addxy.com
        b.tile.addxy.com www.b.tile.addxy.com
        c.tile.addxy.com www.c.tile.addxy.com;
    root /data/tile;
}

proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

## Tile Server

Tile server will convert the OSGeo tile schema to Google Maps/OpenStreetMap schema.

Run the `tile_server.py` using Gunicorn

```bash
$ gunicorn -w 4 -b 127.0.0.1:5000 tile_server:app

2015-10-31 00:49:44 [10011] [INFO] Starting gunicorn 17.5
2015-10-31 00:49:44 [10011] [INFO] Listening at: http://127.0.0.1:5000 (10011)
2015-10-31 00:49:44 [10011] [INFO] Using worker: sync
2015-10-31 00:49:44 [10016] [INFO] Booting worker with pid: 10016
2015-10-31 00:49:44 [10019] [INFO] Booting worker with pid: 10019
2015-10-31 00:49:44 [10022] [INFO] Booting worker with pid: 10022
2015-10-31 00:49:44 [10023] [INFO] Booting worker with pid: 10023
```

### Tile Mapping Service

#### Brockville Airport

**JOSM**

- tms[22]:http://{switch:a,b,c}.tile.addxy.com/brockville/{zoom}/{x}/{y}.png?api_key=123

**iD Editor**

- http://{switch:a,b,c}.tile.addxy.com/brockville/{zoom}/{x}/{y}.png?api_key=123


**Good tile**

- http://tile.addxy.com/brockville/18/75910/94669.png?api_key=123

**Bad credentials**

- http://tile.addxy.com/brockville/18/75910/94669.png?api_key=321

**Missing tile**

- http://a.tile.addxy.com/brockville/24/0/0.png?api_key=123
