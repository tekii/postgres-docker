#!/bin/bash
# exit on error
#set -e

# Preconditions

# user must be postgres

# PG_DATA must be defined

# 
if [ ! -d "${PG_DATA}" ]; then
    # creates the cluster 
    initdb --pgdata=${PG_DATA}
    echo "starting......."
    /usr/lib/postgresql/${PG_MAJOR}.${PG_MINOR}/bin/postgres -D ${PG_DATA} &
    pid="$!"
    echo "started.......${pid}"
    
    # checks for database initialization scripts
    if [ -d ${HOME}/db.d ]; then
        echo 'a.......'
        for file in ${HOME}/db.d/*.sh; do
            echo "b.......${file}"
            source ${file};
        done
    fi

    echo "stoping......."
  
    if ! kill -s TERM "${pid}" || ! wait "${pid}"; then
	echo 'PostgreSQL init process failed'
	exit 1
    fi
    echo "stoped......."
    
    # listen in all interfaces
    sed -ri "s/#(listen_addresses) .*$/\1 = '*'\t\t# MODIFIED BY docker-entrypoint.sh/" \
        ${PG_DATA}/postgresql.conf 

    echo "host all all 0.0.0.0/0 md5" >> ${PG_DATA}/pg_hba.conf

    #
fi

#
/usr/lib/postgresql/${PG_MAJOR}.${PG_MINOR}/bin/postgres -D ${PG_DATA}
