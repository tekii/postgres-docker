#
# postgres Dockerfile
#
FROM launcher.gcr.io/google/debian9:latest

MAINTAINER Pablo Jorge Eduardo Rodriguez <pr@tekii.com.ar>

LABEL version="9.3"
# http://gce_debian_mirror.storage.googleapis.com
# http://http.debian.net/debian
#
# from https://github.com/docker-library/postgres -> make the
# "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && \
    apt-get dist-upgrade --assume-yes && \
    apt-get install -y --no-install-recommends locales gnupg2 dirmngr && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list && \
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 \
    --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
    apt-get update && \
    apt-get purge --assume-yes gnupg2 dirmngr && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# PG_DATA is not PGDATA
ENV PG_MAJOR=9 \
    PG_MINOR=3 \
    PG_PORT=5432 \
    PG_DATA=/var/lib/postgresql/9.3/main \
    HOME=/var/lib/postgresql \
    SECRETS=/run/secrets \
    LANG=en_US.utf8 \
    PATH=$PATH:/usr/lib/postgresql/9.3/bin

RUN groupadd --system --gid 2000 --key PASS_MAX_DAYS=-1 postgres && \
    useradd --system --gid 2000 --key PASS_MAX_DAYS=-1 --uid 2000 \
            --home-dir /var/lib/postgresql \
            --shell /bin/bash --comment "Account for running postgres" postgres  && \
    mkdir -p /var/lib/postgresql && \
    chown -R postgres.postgres /var/lib/postgresql
#
RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends postgresql-common && \
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf && \
    apt-get install -y --no-install-recommends postgresql-9.3 && \
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
VOLUME /run/secrets
# Postgres data volume place-holder
VOLUME /var/lib/postgresql

EXPOSE 5432

USER postgres

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
