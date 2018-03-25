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

## Simulate some data
```bash
# Simulate high CPU
for i in 1 2 3 4 5 6
do
  sleep 5 
  LOAD=$(curl -s 'https://www.random.org/integers/?num=1&min=75&max=100&col=1&base=10&format=plain&rnd=new')
  curl -XPOST "http://localhost:8086/write?db=mydb" \
  -d "cpu,host=server01,region=uswest load=${LOAD} $(date +%s)000000000"
done

# Simulate deploying an upgrade
curl -XPOST "http://localhost:8086/write?db=mydb&precision=s" \
--data-binary 'events title="Deployed v10.2.0",text="<a href='https://github.com'>Release notes</a>",tags="Std Change,Servers,Infra,Upgrade,gpratt" '$(date +%s)
sleep 5

# Simulate reboot
curl -XPOST "http://localhost:8086/write?db=mydb" \
-d "cpu,host=server01,region=uswest load=0 $(date +%s)000000000"

for i in 1 2 3 4 5 6
do
  sleep 5 
  LOAD=$(curl -s 'https://www.random.org/integers/?num=1&min=40&max=49&col=1&base=10&format=plain&rnd=new')
  curl -XPOST "http://localhost:8086/write?db=mydb" \
  -d "cpu,host=server01,region=uswest load=${LOAD} $(date +%s)000000000"
done

curl -XPOST "http://localhost:8086/write?db=mydb&precision=s" \
--data-binary 'events title="Deployed v10.2.1",text="<a href='https://github.com'>Release notes</a>",tags="Emg Change,Servers,Infra,Patch,amerritt" '$(date +%s)
sleep 5
# Simulate reboot
curl -XPOST "http://localhost:8086/write?db=mydb" \
-d "cpu,host=server01,region=uswest load=0 $(date +%s)000000000"
sleep 5

while :
do
  LOAD=$(curl -s 'https://www.random.org/integers/?num=1&min=1&max=29&col=1&base=10&format=plain&rnd=new')
  curl -XPOST "http://localhost:8086/write?db=mydb" \
  -d "cpu,host=server01,region=uswest load=${LOAD} $(date +%s%N)"
  sleep 5
done
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


