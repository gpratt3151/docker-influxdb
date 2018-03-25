# influxdb makefile

# Environment Varibles
CONTAINER = gpratt-influxdb

.PHONY: up

config :
	docker run --rm influxdb influxd config > influxdb.conf

prep :
	mkdir -p \
		data/influx \
		log/influx \

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

