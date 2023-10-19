#
# $Id$
#
# run docker against a volume created with docker volume create
docker run -d --rm --name bg_postgres -m 1G -p 5433:5432 -v betgraph_postgres:/var/lib/postgresql/data -e POSTGRES_PASSWORD=password timescale/timescaledb:latest-pg14

