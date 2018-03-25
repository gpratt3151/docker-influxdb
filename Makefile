# influxdb makefile

# Environment Varibles
CONTAINER = gpratt-influxdb

.PHONY: up

config :
	docker run --rm influxdb influxd config > influxdb.conf

prep :
	mkdir -p \
                data/influxdb \
		data/influxdb/meta \
		data/influxdb/data \
		data/influxdb/wal \
		log/influxdb \

pull :
	docker-compose pull

up : prep pull
	docker-compose up -d

down :
	docker-compose down

shell :
	docker exec -ti $(CONTAINER) /bin/bash

tail :
	docker logs -f $(CONTAINER)

