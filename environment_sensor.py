#!/usr/bin/env python3

import Adafruit_DHT as dht
from time import sleep
from datetime import datetime

from influxdb_client import InfluxDBClient, Point, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS

bucket = "environment"
org    = "Environmental Services"

with open('token', 'r') as file:
    token = file.read().replace('\n', '')

client = InfluxDBClient(url="http://localhost:8086", token=token)
write_api = client.write_api(write_options=SYNCHRONOUS)

DHT = 4

while True:
	h, t = dht.read_retry(dht.AM2302, DHT)
	t = (t * 9/5) + 32

	the_time = datetime.utcnow()

	tp = Point("temperature").tag("pi","9cf").field("temperature",t).time(the_time, WritePrecision.NS)
	hp = Point("humidity").tag("pi", "9cf").field("humidity", h).time(the_time, WritePrecision.NS)

	write_api.write(bucket, org, tp)
	write_api.write(bucket, org, hp)

	print('Temp={0:0.1f} F  Humidity={1:0.1f}%'.format(t,h))
	
	sleep(60) # Read every minute
