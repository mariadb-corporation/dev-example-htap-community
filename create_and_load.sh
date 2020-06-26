#!/bin/bash

# You can change from using root here
#user=$1
#pass=$2
#mariadb+=" --user ${user} -p${pass}"

mariadb="mariadb"

echo "creating schema..."

# Create travel database and airports, airlines, flights tables
${mariadb} < sql/schema.sql

echo "schema created"
echo "loading data..."

# Load airlines into travel.airlines
${mariadb} -e "LOAD DATA LOCAL INFILE 'data/airlines.csv' INTO TABLE airlines FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n'" tx

echo '- airlines.csv loaded into travel.airlines'

# Load airports into travel.airlines
${mariadb} -e "LOAD DATA LOCAL INFILE 'data/airports.csv' INTO TABLE airports FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' LINES TERMINATED BY '\n'" tx
echo '- airports.csv loaded into travel.airports'

# Load flights data into travel_history.flights
cpimport "travel_history" "flights" "data/flights.csv" -s "," -E '"'