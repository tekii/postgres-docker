#
# postgres Dockerfile
# 
FROM google/debian:wheezy

MAINTAINER Pablo Jorge Eduardo Rodriguez <pr@tekii.com.ar>

LABEL version="__PG_MAJOR__.__PG_MINOR__"

# from https://github.com/docker-library/postgres -> make the
# "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV PG_MAJOR=__PG_MAJOR__ \
    PG_MINOR=__PG_MINOR__ \
    PG_PORT=__PG_PORT__ \
    PGDATA=__PG_DATA__ \
    LANG=en_US.utf8 \
    PATH=$PATH:/usr/lib/postgresql/__PG_MAJOR__.__PG_MINOR__/bin

RUN groupadd --system --gid 2000 --key PASS_MAX_DAYS=-1 postgres && \
    useradd --system --gid 2000 --key PASS_MAX_DAYS=-1 --uid 2000 \
            --home-dir __PG_HOME__ \
            --shell /bin/bash --comment "Account for running postgres" \
            postgres
    

# IT-200 - check is this chown actually works...
#RUN mkdir -p __PG_HOME__ && \
#    chown -R postgres.postgres __PG_HOME__

#COPY __POSTGRES_ROOT__ /opt/refine/

#RUN chown --recursive root.root /opt/refine

#  sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-common && \
    apt-get install -y --no-install-recommends postgresql-__PG_MAJOR__.__PG_MINOR__ && \
    rm -rf /var/lib/apt/lists/*

# you must 'chown 2000.2000 .' this directory in the host in order to
# allow the refine user to write in it.
VOLUME __PG_HOME__

EXPOSE __PG_PORT__

USER postgres

#ENTRYPOINT ["/opt/refine/refine", ""]
