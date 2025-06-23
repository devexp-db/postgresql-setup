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
systemctl start postgresql

# check if it is running
systemctl is-active postgresql && echo "PostgreSQL is running" || { echo "PostgreSQL is NOT running"; exit 1; }
