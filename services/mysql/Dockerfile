ARG MYSQL_VERSION
FROM mysql:${MYSQL_VERSION:-latest}

ENV MYSQL_RANDOM_ROOT_PASSWORD=yes

CMD ["mysqld", \
     "--datadir=/tmp/mysqldata", \
     "--event-scheduler=ON", \
     "--slow_query_log=1", \
     "--log-output=TABLE", \
     "--log-queries-not-using-indexes=1", \
     "--max_allowed_packet=536870912"]

HEALTHCHECK --interval=1s --retries=120 \
  CMD mysqladmin ping -h localhost