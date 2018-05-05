#!/bin/bash
# exit on error
#set -e

#INITDB
POSTGRESQL=/usr/lib/postgresql/${PG_MAJOR}.${PG_MINOR}/bin/postgres

# Preconditions

# user must be postgres

# PG_DATA must be defined

#
if [ ! -d "${PG_DATA}" ]; then
    #
    echo "ENTRYPOINT: creating ${PG_DATA} cluster."
    # creates the cluster
    initdb --pgdata=${PG_DATA}
    # listen in all interfaces
    sed -ri "s/#(listen_addresses) .*$/\1 = '*'\t\t# MODIFIED BY docker-entrypoint.sh/" \
        ${PG_DATA}/postgresql.conf
    echo "host all all 0.0.0.0/0 md5" >> ${PG_DATA}/pg_hba.conf

    if ! [ -z ${DB_DATABASE} ] && ! [ -z ${DB_USERNAME} ] &&  ! [ -z ${DB_PASSWORD} ]; then
        # start server to run init scripts
        ${POSTGRESQL} -D ${PG_DATA} &
        pid="$!"
        echo "ENTRYPOINT: postgres starts with ${pid}."
        # TODO: review this
        sleep 3
        #
        #DB_DATABASE=$(<${SECRETS}/database)
        #DB_USERNAME=$(<${SECRETS}/username)
        #DB_PASSWORD=$(<${SECRETS}/password)

        echo "ENTRYPOINT: about to create database:${DB_DATABASE} username:${DB_USERNAME}"
        #echo "ENTRYPOINT: ${DB_PASSWORD}"

        PSQL_FLAGS="--no-psqlrc --quiet"

        psql ${PSQL_FLAGS} --command="CREATE ROLE ${DB_USERNAME} PASSWORD '${DB_PASSWORD}' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;"
        psql ${PSQL_FLAGS} --command="CREATE DATABASE ${DB_DATABASE} WITH OWNER ${DB_USERNAME} ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;"

        echo "ENTRYPOINT: stoping ${pid}."
        #
        if ! kill -s TERM "${pid}" || ! wait "${pid}"; then
	    echo 'PostgreSQL init process failed'
	    exit 1
        fi
        echo "ENTRYPOINT: ${pid} stoped."
    else
        echo "ENTRYPOINT: some secrets are missing."
        exit 1
    fi
fi

# start server in foreground
${POSTGRESQL} -D ${PG_DATA}

echo "ENTRYPOINT: exit."
