# ----------------- #
#   Configuration   #
# ----------------- #

RUN	mkdir -p /var/lib/influxdb
	mkdri -p /var/lib/influxdb/meta
	mkdir -p /var/lib/influxdb/data
	mkdir -p /var/lib/influxdb/wal

# Configure influxdb
RUN	mkdir -p /etc/influxdb
ADD	./influxdb.conf /etc/influxdb/influxdb.conf

# ---------------- #
#   Expose Ports   #
# ---------------- #

# influxdb
EXPOSE	8086

# -------- #
#   Run!   #
# -------- #

CMD	["/usr/bin/influxd" "-config" "/etc/influxdb/influxdb.conf"]
