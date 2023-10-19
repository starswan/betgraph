#
# $Id$
#
# Need to remove the memory limitation when restoring a backup from MySql
#docker run -d --rm --name starswan_postgres -m 2G -p 5433:5432 -v starswan_postgres:/var/lib/postgresql/data -e TZ=London -e POSTGRES_PASSWORD=password timescale/timescaledb:latest-pg14
docker run -d --rm --name starswan_postgres -p 5433:5432 -v starswan_postgres:/var/lib/postgresql/data -e TZ=London -e POSTGRES_PASSWORD=password timescale/timescaledb:latest-pg14

