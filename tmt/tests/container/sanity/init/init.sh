#!/bin/bash
# prep
git clone "$TESTING_FARM_GIT_URL" repo
cd repo
git fetch origin "$TESTING_FARM_GIT_REF"
git checkout FETCH_HEAD

# setup
autoreconf -vfi
./configure --prefix=/usr
make

# initialization
./bin/postgresql-setup --init

# start postgresql
PGDATA=/var/lib/pgsql/data
LOGFILE=/var/lib/pgsql/logfile
/usr/bin/pg_ctl -D $PGDATA -l $LOGFILE start

# check if it is running
pg_ctl -D $PGDATA status && echo "PostgreSQL is running" || { echo "PostgreSQL is NOT running"; exit 1; }
