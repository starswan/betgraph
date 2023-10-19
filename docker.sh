#
# $Id$
#
# run docker against a volume created with docker volume create
docker run -d --rm --name bg_timescale -m 1G -p 5434:5432 -v betgraph_timescale:/var/lib/postgresql/data -e POSTGRES_PASSWORD=password timescale/timescaledb:latest-pg14
