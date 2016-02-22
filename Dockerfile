FROM ubuntu:trusty
MAINTAINER Denis Carriere<carriere.denis@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update \
&& apt-get -qq -y --no-install-recommends install \
    autoconf \
    automake \
    build-essential \
    curl \
    libcurl3-gnutls-dev \
    libepsilon-dev \
    libexpat-dev \
    libfreexl-dev \
    libgeos-dev \
    libgif-dev \
    libhdf4-alt-dev \
    libhdf5-serial-dev \
    libjpeg-dev \
    liblcms2-dev \
    liblzma-dev \
    libnetcdf-dev \
    libpcre3-dev \
    libpng12-dev \
    libpodofo-dev \
    libpoppler-dev \
    libproj-dev \
    libspatialite-dev \
    libsqlite3-dev \
    libtbb2 \
    libwebp-dev \
    libxerces-c-dev \
    libxml2-dev \
    netcdf-bin \
    poppler-utils \
    python-dev \
    unixodbc-dev \
    unzip \
    wget \
    software-properties-common

# Get ECW
ENV ECW_DIR /opt/ecw
RUN mkdir -p $ECW_DIR && \
    curl https://s3-us-west-2.amazonaws.com/addxy.com/SDK/ERDAS-ECW_JPEG_2000_SDK-5.2.1.tar.gz | \
    tar xz -C $ECW_DIR

# Get MrSID
ENV MRSID_DIR /opt/mrsid
RUN mkdir -p $MRSID_DIR && \
    curl https://s3-us-west-2.amazonaws.com/addxy.com/SDK/MrSID_DSDK-9.5.1.4427-linux.x86-64.gcc44.tar.gz | \
    tar xz -C $MRSID_DIR

# Get FileGDB
ENV FILEGDB_DIR /opt/filegdb
RUN mkdir -p $FILEGDB_DIR && \
    curl https://s3-us-west-2.amazonaws.com/addxy.com/SDK/FileGDB_API-64.tar.gz | \
    tar xz -C $FILEGDB_DIR

# Build GDAL from source
ENV GDAL_VERSION 1.11.1
RUN mkdir -p /usr/local/src && \
    curl http://download.osgeo.org/gdal/$GDAL_VERSION/gdal-$GDAL_VERSION.tar.gz | \
    tar xz -C /usr/local/src

WORKDIR /usr/local/src/gdal-$GDAL_VERSION

RUN ./configure \
    --prefix=/usr/local \
    --without-libtool \
    --with-ecw=$ECW_DIR \
    --with-epsilon \
    --with-libkml \
    --with-liblzma \
    --with-mrsid=$MRSID_DIR/Raster_DSDK \
    --with-mrsid_lidar=$MRSID_DIR/Lidar_DSDK \
    --with-fgdb=$FILEGDB_DIR \
    --with-poppler \
    --with-python \
    --with-spatialite \
    --with-threads \
    --with-webp \
&& make \
&& make install \
&& ldconfig

# Install Geoserver
ENV GEOSERVER_HOME /opt/geoserver
ENV JAVA_HOME /usr
ENV GDAL_PATH /usr/share/gdal
ENV GDAL_DATA $GDAL_PATH/1.10
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/lib/jni:/usr/share/java:/opt/ecw/lib/x64/release:/opt/mrsid/Raster_DSDK/lib:/opt/mrsid/Lidar_DSDK/lib:/opt/filegdb/lib

RUN dpkg-divert --local --rename --add /sbin/initctl

# Install packages
RUN \
     \
  apt-get -y install unzip software-properties-common && \
  echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get -y update && \
  apt-get install -y oracle-java7-installer libgdal-java && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk7-installer && \
  rm -rf /tmp/* /var/tmp/*

ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

# Get native JAI and ImageIO
RUN \
    cd $JAVA_HOME && \
    wget http://data.boundlessgeo.com/suite/jai/jai-1_1_3-lib-linux-amd64-jdk.bin && \
    echo "yes" | sh jai-1_1_3-lib-linux-amd64-jdk.bin && \
    rm jai-1_1_3-lib-linux-amd64-jdk.bin

RUN \
    cd $JAVA_HOME && \
    export _POSIX2_VERSION=199209 &&\
    wget http://data.opengeo.org/suite/jai/jai_imageio-1_1-lib-linux-amd64-jdk.bin && \
    echo "yes" | sh jai_imageio-1_1-lib-linux-amd64-jdk.bin && \
    rm jai_imageio-1_1-lib-linux-amd64-jdk.bin

#
# GEOSERVER INSTALLATION
#
ENV GEOSERVER_VERSION 2.8.2
ENV GEOSERVER_URL http://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION

# Get GeoServer
RUN wget -c $GEOSERVER_URL/geoserver-$GEOSERVER_VERSION-bin.zip -O ~/geoserver.zip && \
    unzip ~/geoserver.zip -d /opt && mv -v /opt/geoserver* /opt/geoserver && \
    rm ~/geoserver.zip

# Get Oracle plugin
ENV PLUGIN oracle
RUN wget -c $GEOSERVER_URL/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

# Get Pyramid plugin
ENV PLUGIN pyramid
RUN wget -c $GEOSERVER_URL/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

# Get ArcSDE plugin
ENV PLUGIN arcsde
RUN wget -c $GEOSERVER_URL/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

# Get ArcSDE plugin
ENV PLUGIN app-schema
RUN wget -c $GEOSERVER_URL/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

# Get JP2000 plugin
ENV PLUGIN jp2k
RUN wget -c $GEOSERVER_URL/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

# Get GDAL plugin
ENV PLUGIN gdal
RUN wget -c $GEOSERVER_URL/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

# Get CSS plugin
ENV PLUGIN css
RUN wget -c $GEOSERVER_URL/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

# Get Excel plugin
ENV PLUGIN excel
RUN wget -c $GEOSERVER_URL/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

# Get printing plugin
ENV PLUGIN printing
RUN wget -c $GEOSERVER_URL/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

# Get import plugin
ENV PLUGIN importer
RUN wget -c $GEOSERVER_URL/extensions/geoserver-$GEOSERVER_VERSION-$PLUGIN-plugin.zip -O ~/geoserver-$PLUGIN-plugin.zip && \
    unzip -o ~/geoserver-$PLUGIN-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-$PLUGIN-plugin.zip

# Replace GDAL Java bindings
RUN cp /usr/share/java/gdal.jar $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/gdal.jar

# Expose GeoServer's default port
EXPOSE 8080

CMD ["/opt/geoserver/bin/startup.sh"]
