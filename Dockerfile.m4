#
# postgres Dockerfile
# 
FROM google/debian:__DISTRO__

MAINTAINER Pablo Jorge Eduardo Rodriguez <pr@tekii.com.ar>

LABEL version="__PG_MAJOR__.__PG_MINOR__"
# http://gce_debian_mirror.storage.googleapis.com
# http://http.debian.net/debian
#
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

# PG_DATA is not PGDATA
ENV PG_MAJOR=__PG_MAJOR__ \
    PG_MINOR=__PG_MINOR__ \
    PG_PORT=__PG_PORT__ \
    PG_DATA=__PG_DATA__ \
    HOME=__PG_HOME__ \
    SECRETS=__SECRETS__ \
    LANG=en_US.utf8 \
    PATH=$PATH:/usr/lib/postgresql/__PG_MAJOR__.__PG_MINOR__/bin

RUN groupadd --system --gid 2000 --key PASS_MAX_DAYS=-1 postgres && \
    useradd --system --gid 2000 --key PASS_MAX_DAYS=-1 --uid 2000 \
            --home-dir __PG_HOME__ \
            --shell /bin/bash --comment "Account for running postgres" postgres  && \
    mkdir -p __PG_HOME__ && \
    chown -R postgres.postgres __PG_HOME__  
# 
RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends postgresql-common && \
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf && \
    apt-get install -y --no-install-recommends postgresql-__PG_MAJOR__.__PG_MINOR__ && \
    rm -rf /var/lib/apt/lists/*

# Mock Kubernetes secret
#RUN mkdir -p __SECRETS__ && \
#    chown -R postgres.postgres __SECRETS__
    
#COPY username __SECRETS__/
#COPY password __SECRETS__/
#COPY database __SECRETS__/

COPY docker-entrypoint.sh /opt/ 

RUN chmod 555 /opt/docker-entrypoint.sh 

#    chown -R postgres.postgres __SECRETS__ && \
#    chmod 500 __SECRETS__ && \
#    chmod -R 400 __SECRETS__/*

# Kubernetes secret place-holder
VOLUME __SECRETS__
# Postgres data volume place-holder
VOLUME __PG_HOME__

EXPOSE __PG_PORT__

USER postgres 

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
