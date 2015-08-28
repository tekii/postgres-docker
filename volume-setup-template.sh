#!/bin/sh
echo "----START"

if [ -f ${SECRETS}/username ] && [ -f ${SECRETS}/password ] && [ -f ${SECRETS}/database ]; then
    #
    DB_USERNAME=$(<${SECRETS}/username)
    DB_PASSWORD=$(<${SECRETS}/password)
    DB_DATABASE=$(<${SECRETS}/database)
    # 
    echo "ENTRYPOINT: ${DB_USERNAME}"
    #echo "ENTRYPOINT: ${DB_PASSWORD}"
    echo "ENTRYPOINT: ${DB_DATABASE}"

    PSQL_FLAGS="--no-psqlrc --quiet"
    
    #SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;
    psql ${PSQL_FLAGS} --command="CREATE ROLE ${DB_USERNAME} PASSWORD '${DB_PASSWORD}';"
    
    psql ${PSQL_FLAGS} --command="CREATE DATABASE ${DB_DATABASE} WITH OWNER ${DB_USERNAME} ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;"
    
    #createuser --no-superuser --createdb --createrole --encrypted ${DB_USERNAME}
    #createdb --owner ${DB_USERNAME} --encoding utf8 ${DB_NAME}
    #createdb --owner ${DB_USERNAME} -E UNICODE -l C -T template0 jiradb

else
    echo "ENTRYPOINT: some secrets are missing."
    exit 1
fi

echo "------END"
