FROM ubuntu:trusty
MAINTAINER Denis Carriere<carriere.denis@gmail.com>


ENV DEBIAN_FRONTEND noninteractive
ENV ECW_DIR /opt/ecw
ENV MRSID_DIR /opt/mrsid

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
RUN wget -c https://s3-us-west-2.amazonaws.com/pacgeo/SDK/ERDAS-ECW_JPEG_2000_SDK-5.2.1.zip -O ~/ecw.zip && \
    unzip ~/ecw.zip -d $ECW_DIR && \
    rm ~/ecw.zip

# Get MrSID
RUN wget -c https://s3-us-west-2.amazonaws.com/pacgeo/SDK/MrSID_DSDK-9.1.0.4045-linux.x86-64.gcc44.zip -O ~/mrsid.zip && \
    unzip ~/mrsid.zip -d $MRSID_DIR && \
    rm ~/mrsid.zip

# Build GDAL from source
ENV GDAL_VERSION 1.11.1

RUN mkdir -p /usr/local/src \
    && curl -s http://download.osgeo.org/gdal/$GDAL_VERSION/gdal-$GDAL_VERSION.tar.gz \
    | tar xz -C /usr/local/src

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
    --with-podofo \
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
ENV GDAL_DATA /usr/local/share/gdal
ENV PATH $GDAL_PATH:$PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/lib/jni:/usr/share/java:/opt/ecw/lib/x64/release:/opt/mrsid/Raster_DSDK/lib:/opt/mrsid/Lidar_DSDK/lib

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
ENV GEOSERVER_VERSION 2.7.3

# Get GeoServer
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-bin.zip -O ~/geoserver.zip &&\
    unzip ~/geoserver.zip -d /opt && mv -v /opt/geoserver* /opt/geoserver && \
    rm ~/geoserver.zip

# Get OGR WPS plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-ogr-plugin.zip -O ~/geoserver-ogr-plugin.zip &&\
    unzip -o ~/geoserver-ogr-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-ogr-plugin.zip

# Get ArcSDE plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-arcsde-plugin.zip -O ~/geoserver-arcsde-plugin.zip &&\
    unzip -o ~/geoserver-arcsde-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-arcsde-plugin.zip

# Get JP2000 plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-jp2k-plugin.zip -O ~/geoserver-jp2k-plugin.zip &&\
    unzip -o ~/geoserver-jp2k-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-jp2k-plugin.zip

# Get GDAL plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-gdal-plugin.zip -O ~/geoserver-gdal-plugin.zip &&\
    unzip -o ~/geoserver-gdal-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-gdal-plugin.zip

# Get CSS plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-css-plugin.zip -O ~/geoserver-css-plugin.zip &&\
    unzip -o ~/geoserver-css-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-css-plugin.zip

# Get Excel plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-excel-plugin.zip -O ~/geoserver-excel-plugin.zip &&\
    unzip -o ~/geoserver-excel-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-excel-plugin.zip

# Get printing plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-printing-plugin.zip -O ~/geoserver-printing-plugin.zip &&\
    unzip ~/geoserver-printing-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-printing-plugin.zip

# Get import plugin
RUN wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-importer-plugin.zip -O ~/geoserver-importer-plugin.zip &&\
    unzip -o ~/geoserver-importer-plugin.zip -d /opt/geoserver/webapps/geoserver/WEB-INF/lib/ && \
    rm ~/geoserver-importer-plugin.zip

# Replace GDAL Java bindings
RUN rm -rf $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/imageio-ext-gdal-bindings-1.9.2.jar
RUN cp /usr/share/java/gdal.jar $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/gdal.jar

# Expose GeoServer's default port
EXPOSE 8080

CMD ["/opt/geoserver/bin/startup.sh"]
