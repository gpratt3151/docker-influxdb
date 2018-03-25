# docker-influxdb
Docker InfluxDB configuration

## Basis of this work
[GitHub project: influxdata/influxdb](https://github.com/influxdata/influxdb).

[Creating Grafana Annotations with InfluxDB](https://maxchadwick.xyz/blog/grafana-influxdb-annotations).

[Using InfluxDB in Grafana > Annotations](http://docs.grafana.org/features/datasources/influxdb/#annotations).

## Create the database
```bash
curl -XPOST "http://localhost:8086/query" --data-urlencode "q=CREATE DATABASE mydb"
```

## Discussion about posting data to InfluxDB
1. Posting of metric data requires nanoseconds accuracy or at least seconds since epoch + 9 zero's (`date +%s%N`)
2. Posting of the "Annotation" cannot be in nanoseconds accuracy and *must* be seconds since epoch (`date +%s`)

Here is the difference between `date +%s` and `date +%s%N`:
```
1521955132
1521955132149562816
```
If you do not have nanoseconds simply append 9 zeros to the seconds since epoch as follows:
```
1521955132000000000
```

## Insert some data
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

## Grafana Configuration
### Create the Data Source
#### Edit data source
Name: `mydb`
Type: `InfluxDB`

##### Http Settings
Url: `http://IP_ADDRESS:8086`
Access: `proxy`

##### InfluxDB Details
Database: `mydb`

### Create the Panel for the Dashboard
#### Graph
##### Metrics
Panel Data Source: `mydb`

A `SELECT "load" FROM "cpu" WHERE $timeFilter`  

Format As: `Time Series`
##### Display
Draw Modes: `[x] Lines [x] Points`

Stacking & Null value Null value: `connect`

### Create the Annotations for the Dashboard
Select the `Cog` at the top of the page

Select the `Annotations`
#### Annotations
##### Queries
Options

Name: `Changes`

Data Source: `mydb`

Query: `select title,tags,text from events where $timeFilter`

Field mappings

Title: `title`

Tags: `tags`

Text: `text`


