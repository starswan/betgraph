#
# $Id$
#
# Need to remove the memory limitation when restoring a backup from MySql
docker run -d --restart always --name betgraph_postgres16 -m 2G -p 5434:5432 -v betgraph_postgres16:/var/lib/postgresql/data -e TZ=London -e POSTGRES_PASSWORD=password timescale/timescaledb:latest-pg16
#docker run -d --restart always --name betgraph_postgres -p 5433:5432 -v betgraph_postgres:/var/lib/postgresql/data -e TZ=London -e POSTGRES_PASSWORD=password timescale/timescaledb:latest-pg14

