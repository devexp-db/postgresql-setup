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

# insert data
su - postgres -c "
echo \"User switched\";

createdb -h /tmp testdb;
psql -h /tmp  -U postgres -d testdb -c \"create table users (id serial primary key, name text)\";
psql -h /tmp -U postgres -d testdb -c \"insert into users (name) values ('Alice'), ('Bob'), ('Celine')\"
"
su - postgres -c '
psql -h /tmp -U postgres -d testdb -c "select * from users"
' > expected.txt

echo "Expected:"
cat expected.txt

test $(wc -l < expected.txt) -gt 0 || { echo "ERROR: expected.txt is empty!"; exit 1; }

# uninstall postgresql
dnf -y remove postgresql-server postgresql-private-libs postgresql libicu

# install postgresql17
dnf -y install postgresql17-upgrade

# run --upgrade
./bin/postgresql-setup --upgrade

su - postgres -c "
/usr/bin/pg_ctl -D $PGDATA -l $LOGFILE -o \"-c unix_socket_directories=/tmp\" start
/usr/bin/pg_ctl -D $PGDATA status && echo \"PostgreSQL is running\" || { echo \"PostgreSQL is NOT running\"; exit 1; }
"

su - postgres -c '
psql -h /tmp -U postgres -d testdb -c "select * from users"
' > actual.txt

echo "Actual:"
cat actual.txt

diff -q expected.txt actual.txt && echo "Actual and expected outputs match" || { echo "Actual and expected outputs differ"; exit 1; }

