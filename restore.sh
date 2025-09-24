#!/bin/bash

DB_USER=${DB_USER:-${PGSQL_ENV_DB_USER}}
DB_PASS=${DB_PASS:-${PGSQL_ENV_DB_PASS}}
DB_NAME=${DB_NAME:-${PGSQL_ENV_DB_NAME}}
DB_HOST=${DB_HOST:-${PGSQL_ENV_DB_HOST}}
FILE=${FILE:-${PGSQL_ENV_RESTORE_FILE}}
FLAGS=${FLAGS}

if [[ ${DB_USER} == "" ]]; then
	echo "Missing DB_USER env variable"
	exit 1
fi
if [[ ${DB_PASS} == "" ]]; then
	echo "Missing DB_PASS env variable"
	exit 1
fi
if [[ ${DB_HOST} == "" ]]; then
	echo "Missing DB_HOST env variable"
	exit 1
fi
if [[ ! $FLAGS == ""]]; then
	FLAGS=" $FLAGS"
fi

PGPASSWORD="$DB_PASS" psql$FLAGS --username=$DB_USER --host=$DB_HOST "${DB_NAME}" < $FILE
