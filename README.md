# HTAP with MariaDB Community Server 10.5

[MariaDB Community Server 10.5](https://mariadb.com/resources/blog/whats-new-in-mariadb-community-server-10-5/) has many enhancements that will provide an improved user experience with faster performance and improved manageability. 

Earlier versions of [MariaDB ColumnStore](https://mariadb.com/docs/features/mariadb-columnstore/) have been available to the open source community as a separate fork of MariaDB. Now, with MariaDB Community Server 10.5, [ColumnStore 1.5](https://mariadb.com/resources/blog/mariadb-columnstore-1-5-now-available-with-mariadb-community-server-10-5/) is included as a pluggable storage engine making a columnar storage engine for analytics easily available to MariaDB Community Server users out-of-the-box. 

MariaDB ColumnStore can be deployed as the analytics component of MariaDB's single stack [Hybrid Transactional/Analytical Processing (HTAP)](https://mdbcdt.com/DOCS-2032/solutions/htap/#htap) solution or as a standalone columnar database for interactive, ad hoc analytics at scale.


**The following is a walkthrough to get you up and running with a MariaDB Community Server (with ColumnStore) (using a Docker Image) and an HTAP database instance in less than 15 minutes.** 

## Prerequisites 

Before getting started with this walkthrough you need to have [Docker installed](https://docs.docker.com/get-docker/). 

## Overview

This walk-through will step you through the process of installing, accessing and configuring HTAP within a MariaDB Community Server (with ColumnStore) instance.

### 1. Installing single-node instance

Pull down the [MariaDB Community Server (with ColumnStore) image](https://hub.docker.com/r/mariadb/columnstore) and create a new container by executing the following command in a terminal window:

```bash
$ docker run -d -p 3306:3306 --name mcs_container mariadb/columnstore
```

### 2. Enter the newly created container

```bash
$ docker exec -it mcs_container bash
```

### 3. Install [git](https://git-scm.com/) using [yum](http://yum.baseurl.org/)

```bash
$ yum install git
```

### 4. Clone this repository

```bash
$ git clone https://github.com/mariadb-corporation/dev-example-htap-community.git
```

### 5. Create schemas and load data

This repository includes the following schemas:

* innodb_db (database)
    * airlines (table) 
    * airports (table) - all airports within the United States of America
    * flights (table)
* columnstore_db (database)
    * flights (table)

In this sample, the [create_and_load.sh](create_and_load.sh) script will be used to create the schemas (via [schema.sql](sql/schema.sql)) and load the following tables:

* innodb_db.airlines - using [data/airlines.csv](data/airlines.csv)
* innodb_db.airports - using [data/airports.csv](data/airports.csv)
* columnstore.db_flights - using [data/flights.csv](data/flights.csv)

Execute the script to create schemas and load data.

```bash
$ ./create_and_load.sh
```

You should output similar to the following:

```

```

Confirm that schema creation and data loading has been successful.

1. Access MariaDB 

```bash
$ mariadb
```

2. Confirm databases have been created.

```sql
$ SHOW DATABASES();
```

You should see the following output:
```

```

3. View table content (and confirm they have data)

```sql
$ SELECT COUNT(*) FROM innodb_db.airlines;
$ SELECT COUNT(*) FROM innodb_db.airports;
$ SELECT COUNT(*) FROM columnstore_db.flights;
```

And because there is a Cross Engine user included within the Community Server 10.5 container you can also test out cross engine (ex. innodb_db <-> columnstore_db) joins.

```sql
$ SELECT a.airline, AVG(f.dep_delay) FROM innodb_db.airlines a INNER JOIN columnstore_db.flights f ON a.iata_code = f.carrier GROUP BY a.airline;
```

4. Exit MariaDB

```bash
$ exit
```

### 6. [Server configuration](https://mariadb.com/docs/deploy/community-htap/#server-configuration)

The following configuration changes will be used to set up replication between innodb_db and columnstore_db. 

Open /etc/my.cnf.d/columnstore.cnf for editing.

```bash 
$ vi /etc/my.cnf.d/columnstore.cnf
```
Make the following configuration changes:

```bash
# Required for Schema Sync
server-id = 1
log_bin=mariadb-bin
log_slave_updates = OFF
binlog_format = STATEMENT

# HTAP filtering rules

# 1. Transactions are replicated from itself
replicate_same_server_id = ON

# 2. Only write queries that tough innodb_db to the binary log
binlog_do_db = tx

# 3. Rewrite innodb_db to columnstore_db prior to applying transaction
replicate_rewrite_db = tx->ax
```

Optional: If you want to restrict replication to occur on certain tables you can use `replicate_wild_do_table`.

```bash
# 4. Only replicate tables that begin with "htap"
replicate_wild_do_table = columnstore_db.htap%
```

Save file and exit. 

### 7. [Starting MariaDB replication](https://mariadb.com/docs/deploy/community-htap/#starting-mariadb-replication)


```bash
$ mariadb < sql/replication.sql
```

### 8. Restart MariaDB container 

```bash
$ exit
$ docker restart mcs_container
```

Then, when running again, re-enter the container.

```bash
$ docker exec -it mcs_container bash
```

### 9. Restart MariaDB ColumnStore

```bash 
$ columnstore-restart
```

### 10. Test replication

You can test replication by inserting a new record into `innodb_db.flights` and confirming that it exists in `columnstore_db.flights`.

1. Access MariaDB

```bash
$ mariadb
```

2. Insert a new record into `innodb_db.flights`.

```sql
$ USE innodb_db;
$ INSERT INTO flights VALUES (2020, 6, 25, 1, '2020-6-25', 'DL', 'N9999', 1000, 'ORD', 'LAX', '0600', '0600', 10);
```

3. Confirm the new record exists in `columnstore_db.flights`.

```sql
$ SELECT * FROM columnstore_db.flights WHERE year = 2020;
```

## More resources

- [Deploy HTAP with MariaDB ColumnStore 1.5 and MariaDB Community 10.5](https://mariadb.com/docs/deploy/community-htap/)
- [Sign up for MariaDB SkySQL](https://mariadb.com/products/skysql/get-started/)
- [Official MariaDB SkySQL Documentation](https://mariadb.com/products/skysql/docs/)

## Support and Contribution <a name="support-contribution"></a>

Thanks so much for taking a look at this walk-through! Please feel free to submit PR's to the project to include your modifications!

If you have any questions, comments, or would like to contribute to this or future projects like this please reach out to us directly at developers@mariadb.com or on [Twitter](https://twitter.com/mariadb).

## License <a name="license"></a>
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=plastic)](https://opensource.org/licenses/MIT)