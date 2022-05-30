#!/bin/bash

DB_USER=${DB_USER:-${PGSQL_ENV_DB_USER}}
DB_PASS=${DB_PASS:-${PGSQL_ENV_DB_PASS}}
DB_NAME=${DB_NAME:-${PGSQL_ENV_DB_NAME}}
DB_HOST=${DB_HOST:-${PGSQL_ENV_DB_HOST}}
ALL_DATABASES=${ALL_DATABASES}
IGNORE_DATABASE=${IGNORE_DATABASE}
TS=$(date +%Y%m%dT%H%M%S)


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

#if [[ ${ALL_DATABASES} == "" ]]; then
	if [[ ${DB_NAME} == "" ]]; then
		echo "Missing DB_NAME env variable"
		exit 1
	fi
  echo "$DB_HOST:5432:$DB_NAME:$DB_USER:$DB_PASS" > ~/.pgpass
  chmod 600 ~/.pgpass
	pg_dump --username="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" "$@" "${DB_NAME}" | gzip -c | cat > /pgsqldump/"${DB_NAME}"_${TS}.sql.gz
#else
#	databases=`mysql --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
#for db in $databases; do
#    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "$IGNORE_DATABASE" ]]; then
#        echo "Dumping database: $db"
#        echo "$DB_HOST:5432:$DB_NAME:$DB_USER:$DB_PASS" > ~/.pgpass
#        chmod 600 ~/.pgpass
#        mysqldump --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" --databases $db | gzip -c | cat > /mysqldump/$db-${TS}.sql.gz
#    fi
#done
#fi
