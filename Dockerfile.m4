#
# postgres Dockerfile
# 
FROM google/debian:__DISTRO__

MAINTAINER Pablo Jorge Eduardo Rodriguez <pr@tekii.com.ar>

LABEL version="__PG_MAJOR__.__PG_MINOR__"
#http://gce_debian_mirror.storage.googleapis.com
# http://http.debian.net/debian
# from https://github.com/docker-library/postgres -> make the
# "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN echo "deb http://gce_debian_mirror.storage.googleapis.com __DISTRO__-backports main" \
    >  /etc/apt/sources.list.d/backports.list && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ __DISTRO__-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list && \
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 \
    --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
    apt-get update && \
    apt-get dist-upgrade --assume-yes && \
    apt-get --target-release __DISTRO__-backports install -y --no-install-recommends locales && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV PG_MAJOR=__PG_MAJOR__ \
    PG_MINOR=__PG_MINOR__ \
    PG_PORT=__PG_PORT__ \
    LANG=en_US.utf8 \
    PATH=$PATH:/usr/lib/postgresql/__PG_MAJOR__.__PG_MINOR__/bin

#PGDATA=__PG_DATA__ \

RUN groupadd --system --gid 2000 --key PASS_MAX_DAYS=-1 postgres && \
    useradd --system --gid 2000 --key PASS_MAX_DAYS=-1 --uid 2000 \
            --home-dir __PG_HOME__ \
            --shell /bin/bash --comment "Account for running postgres" postgres
# 
RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends postgresql-common && \
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf && \
    apt-get install -y --no-install-recommends postgresql-__PG_MAJOR__.__PG_MINOR__ && \
    rm -rf /var/lib/apt/lists/*

#COPY *.conf /etc/postgresql/__PG_MAJOR__.__PG_MINOR__/main/

#RUN chown postgres.postgres /etc/postgresql/__PG_MAJOR__.__PG_MINOR__/main/postgresql.conf && \
#    chown postgres.postgres /etc/postgresql/__PG_MAJOR__.__PG_MINOR__/main/pg_hba.conf 

VOLUME __PG_HOME__
EXPOSE __PG_PORT__

USER postgres 

#RUN initdb --username=postgres --pgdata=__PG_DATA__ 


#ENTRYPOINT ["/usr/lib/postgresql/__PG_MAJOR__.__PG_MINOR__/bin/postgres", "--config-file=/etc/postgresql/__PG_MAJOR__.__PG_MINOR__/main/postgresql.conf"]
    
