FROM alpine:3.24

# pg_dump refuses to dump a server newer than itself, so the client major must
# be >= the servers being backed up (PostgreSQL 17 today). Pin it explicitly:
# plain postgresql-client follows Alpine's default and is 16 on Alpine 3.24.
ARG PG_MAJOR=17

RUN apk add --no-cache "postgresql${PG_MAJOR}-client" bash

COPY dump.sh /
ENTRYPOINT ["/dump.sh"]
