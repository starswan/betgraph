# run docker against a volume created with docker volume create
#
docker run --name timescaledb -d -p 5432:5432 -v pgdata:/home/postgres/pgdata/data -e POSTGRES_PASSWORD=password timescale/timescaledb-ha:pg14-latest
