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

    # checks for database initialization scripts in the persistent
    # volume.
    if [ -d ${HOME}/db.d ]; then
        # start server to run init scripts
        ${POSTGRESQL} -D ${PG_DATA} &
        pid="$!"
        echo "ENTRYPOINT: postgres starts with ${pid}."
        # TODO: review this
        sleep 3
        
        for file in ${HOME}/db.d/*.sh; do
            echo "ENTRYPOINT: running local init script ${file}."
            source ${file}; # pass secrets here
        done
   
        echo "ENTRYPOINT: stoping ${pid}."
        #
        if ! kill -s TERM "${pid}" || ! wait "${pid}"; then
	    echo 'PostgreSQL init process failed'
	    exit 1
        fi
        echo "ENTRYPOINT: ${pid} stoped."
    fi
fi

# start server in foreground
${POSTGRESQL} -D ${PG_DATA}

echo "ENTRYPOINT: exit."
