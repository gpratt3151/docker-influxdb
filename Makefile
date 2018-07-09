# influxdb makefile

# Environment Varibles
CONTAINER = gpratt-influxdb

.PHONY: up

config :
	sudo docker run --rm influxdb influxd config > influxdb.conf

prep :
	mkdir -p \
                data/influxdb \
		data/influxdb/meta \
		data/influxdb/data \
		data/influxdb/wal \
		log/influxdb \

pull :
	sudo docker-compose pull

up : prep pull
	sudo docker-compose up -d

down :
	sudo docker-compose down

shell :
	sudo docker exec -ti $(CONTAINER) /bin/bash

tail :
	sudo docker logs -f $(CONTAINER)

