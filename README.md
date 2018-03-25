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

## Grafana Configuration
Import the `SampleDashboard.json` or configure the dashboard as follows:

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
Graph > Metrics
```
Panel Data Source: mydb v

v A FROM      default cpu WHERE +
    SELECT    field(load) mean() +
    GROUP BY  time($_interval) fill(null) +
    FORMAT AS Time series v
    ALIAS BY  Naming pattern
```

Graph > Display
```
Draw Modes: 
  [x] Lines 
  [x] Points

Stacking & Null value
  Null value connect v
```


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

## Simulation Discussion
The way the following program works is:
1. The default behavior is to simulate a load at or above 90%
2. When CTRL-C is trapped it simulates an upgrade with reboot
3. This only partially solves the problem and only brings the CPU down marginally
4. A simulated patch is deployed with reboot
5. This solves the performance problem

## Recommended Demonstration for Management
1. Prior to going into your demonstration, start the [script](simulate.sh) (preferrably using `screen` in case you get disconnected)
2. Explain to management that users have been complaining about slow performance and that root cause analysis has identifid high CPU on the server 
3. At this point switch over to the terminal where you have the script running and hit CTRL-C
4. As described above, the script will step through a simulated upgrade, reboot, patch and final reboot
5. Problem solved and fully documented!
