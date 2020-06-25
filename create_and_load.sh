#!/bin/bash

#user=$1
#pass=$2

mariadb="mariadb"
# use the arguments to connect to MariaDB SkySQl
#if [ -z "$user" && -z "$pass" ]
#then
    #mariadb+=" --user ${user} -p${pass}"
#fi

echo "creating schema..."

# create travel database and airports, airlines, flights tables
${mariadb} < schema.sql

echo "schema created"
echo "loading data..."

# Load airlines into travel.airlines
${mariadb} -e "LOAD DATA LOCAL INFILE 'data/airlines.csv' INTO TABLE airlines FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n'" tx

echo '- airlines.csv loaded into tx.airlines'

# Load airports into travel.airlines
${mariadb} -e "LOAD DATA LOCAL INFILE 'data/airports.csv' INTO TABLE airports FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n'" tx
echo '- airports.csv loaded into tx.airports'

# Load flights data into travel_history.flights
cpimport "ax" "flights" "data/flights.csv"