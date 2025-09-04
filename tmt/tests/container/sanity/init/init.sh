#!/bin/bash
# prep
git clone "$REPO_URL" repo
cd repo
git fetch origin "$PR_HEAD"
git checkout FETCH_HEAD

grep -q systemd /proc/1/comm
echo "Return value CONTAINER: $?"

# setup
autoreconf -vfi
./configure --prefix=/usr
make

# initialization
./bin/postgresql-setup --init

# start postgresql and check if it's running
PGDATA=/var/lib/pgsql/data
LOGFILE=/var/lib/pgsql/logfile
su - postgres -c "
/usr/bin/pg_ctl -D $PGDATA -l $LOGFILE -o \"-c unix_socket_directories=/tmp\" start
/usr/bin/pg_ctl -D $PGDATA status && echo \"PostgreSQL is running\" || { echo \"PostgreSQL is NOT running\"; exit 1; }
"

