#
# $Id$
#
# run docker against a volume created with docker volume create
docker run --rm --name betgraph_db -m 1G -p 5433:5432 -v betgraph_data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=password timescale/timescaledb:latest-pg14

