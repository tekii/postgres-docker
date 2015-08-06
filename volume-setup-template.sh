#!/bin/sh
echo "----START"

if [ -f ${SECRETS}/credentials ]; then
    #
    source ${SECRETS}/credentials
    # DB_USERNAME must be defined
    echo "ENTRYPOINT: ${DB_USERNAME}"
    # DB_PASSWORD must be defined
    echo "ENTRYPOINT: ${DB_PASSWORD}"

    PSQL_FLAGS="--no-psqlrc --quiet"
    
    #SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;
    psql ${PSQL_FLAGS} --command="CREATE ROLE ${DB_USERNAME} PASSWORD '${DB_PASSWORD}';"
    
    psql ${PSQL_FLAGS} --command="CREATE DATABASE ${DB_NAME} WITH OWNER ${DB_USERNAME} ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;"
    
    #createuser --no-superuser --createdb --createrole --encrypted ${DB_USERNAME}
    #createdb --owner ${DB_USERNAME} --encoding utf8 ${DB_NAME}
    #createdb --owner ${DB_USERNAME} -E UNICODE -l C -T template0 jiradb


else
    echo "ENTRYPOINT: ${HOME}/credentials not found."
    exit 1
fi

echo "------END"
