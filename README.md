# docker-influxdb
Docker InfluxDB configuration

## Basis of this work
[GitHub project: influxdata/influxdb](https://github.com/influxdata/influxdb).

[Creating Grafana Annotations with InfluxDB](https://maxchadwick.xyz/blog/grafana-influxdb-annotations).

[Using InfluxDB in Grafana > Annotations](http://docs.grafana.org/features/datasources/influxdb/#annotations).

### Create the database
```bash
curl -XPOST "http://localhost:8086/query" --data-urlencode "q=CREATE DATABASE mydb"
```

### Insert some data
Some things to note:
1. Posting of metric data requires nanoseconds accuracy or at least seconds since epoch + 9 zero's
2. Posting of the "Annotation" cannot be in nanoseconds accuracy and *must* be seconds since epoch

```bash
curl -XPOST "http://localhost:8086/write?db=mydb" \
-d 'cpu,host=server01,region=uswest load=42 '$(date +%s%N)
sleep 2
curl -XPOST "http://localhost:8086/write?db=mydb" \
-d 'cpu,host=server02,region=uswest load=78 '$(date +%s%N)
sleep 1
curl -XPOST "http://localhost:8086/write?db=mydb" \
-d 'cpu,host=server02,region=uswest load=78 '$(date +%s%N)
curl -XPOST "http://localhost:8086/write?db=mydb&precision=s" \
--data-binary 'events title="Deployed v10.2.0",text="<a href='https://github.com'>Release notes</a>",tags="these,are,the,tags" '$(date +%s)
sleep 2
curl -XPOST "http://localhost:8086/write?db=mydb" \
-d 'cpu,host=server03,region=useast load=15.4 '$(date +%s%N)
sleep 2
curl -XPOST "http://localhost:8086/write?db=mydb" \
-d 'cpu,host=server03,region=useast load=16 '$(date +%s%N)
sleep 1
curl -XPOST "http://localhost:8086/write?db=mydb" \
-d 'cpu,host=server03,region=useast load=13 '$(date +%s%N)
```

