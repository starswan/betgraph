# run docker against a volume created with docker volume create
#
#docker container prune -f
# This version doesm't seem to work properly when timescaledb starts up
#docker run --name timescaledb -p 5432:5432 -v pgdata:/home/postgres/pgdata/data -e POSTGRES_PASSWORD=password timescale/timescaledb:latest-pg14
docker run --name betgraph_db -p 5433:5432 -v betgraph_data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=password timescale/timescaledb-ha:pg14-all

