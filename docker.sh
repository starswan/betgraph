#
# $Id$
#
# Need to remove the memory limitation when restoring a backup from MySql
docker run -d --rm --name starswan_betgraph_postgres -m 1G -p 5433:5432 -v starswan_betgraph:/var/lib/postgresql/data -e TZ=London -e POSTGRES_PASSWORD=password timescale/timescaledb:latest-pg14
#docker run -d --rm --name starswan_betgraph_postgres -p 5433:5432 -v starswan_betgraph:/var/lib/postgresql/data -e TZ=London -e POSTGRES_PASSWORD=password timescale/timescaledb:latest-pg14
