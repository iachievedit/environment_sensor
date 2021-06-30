#!/bin/bash

# Run as sudo or die

apt-get install -y python3

pip3 install -r requirements.txt

mkdir -p /opt/influxdb/bin
mkdir -p /usr/local/bin

INFLUXDB_DIST=influxdb2-2.0.7-linux-arm64
INFLUXDB_DIST_PKG=${INFLUXDB_DIST}.tar.gz

if [ ! -e $INFLUXDB_DIST_PKG ]; then
  wget https://dl.influxdata.com/influxdb/releases/${INFLUXDB_DIST_PKG}
  tar xvfz ${INFLUXDB_DIST_PKG}
  cp $(INFLUXDB_DIST)/* /opt/influxdb/bin/
fi

user_exists=$(id influxdb > /dev/null 2>&1; echo $?)

if [[ "$user_exists" != "0" ]]; then
  useradd influxdb --create-home
fi

echo "Installing application"
cp environment_sensor.py /usr/local/bin/
chmod +x environment_sensor.py

echo "Installing systemd services"
cp *.service /etc/systemd/system/
systemctl enable influxdb
systemctl restart influxdb
systemctl enable environment_sensor
systemctl restart environment_sensor
