#!/bin/bash
# prep
git clone "$REPO_URL" repo
cd repo
git fetch origin "$PR_HEAD"
git checkout FETCH_HEAD
git log -1 --oneline

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
