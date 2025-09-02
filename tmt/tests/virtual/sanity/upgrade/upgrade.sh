#!/bin/bash
# prep
git clone "$REPO_URL" repo
cd repo
git fetch origin "$PR_HEAD"
git checkout FETCH_HEAD
echo "Fedora release:"
cat /etc/fedora-release
dnf list -y postgresql* --available


# install postgresql16
dnf -y install postgresql16-server

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

# insert data
su - postgres -c "
echo \"User switched\"; 

createdb testdb;
psql -U postgres -d testdb -c \"create table users (id serial primary key, name text)\";
psql -U postgres -d testdb -c \"insert into users (name) values ('Alice'), ('Bob'), ('Celine')\"
"
su - postgres -c '
psql -U postgres -d testdb -c "select * from users"
' > expected.txt

echo "Expected:"
cat expected.txt

# uninstall postgresql 
dnf -y remove postgresql-server postgresql-private-libs postgresql libicu

# install postgresql17
dnf -y install postgresql17-upgrade

# run --upgrade
./bin/postgresql-setup --upgrade

# restart postgresql
systemctl start postgresql

# check if it is running
systemctl is-active postgresql && echo "PostgreSQL is running" || { echo "PostgreSQL is NOT running"; exit 1; }

su - postgres -c '
psql -U postgres -d testdb -c "select * from users"
' > actual.txt

echo "Actual:"
cat actual.txt

diff -q expected.txt actual.txt && echo "Actual and expected outputs match" || { echo "Actual and expected outputs differ"; exit 1; }






