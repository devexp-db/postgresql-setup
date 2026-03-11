#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k

. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
  rlPhaseStartSetup
    rlRun "git clone \"$REPO_URL\" repo"
    rlRun "pushd repo"
    rlRun "git fetch origin \"$PR_HEAD\""
    rlRun "git checkout FETCH_HEAD"
    rlRun "cat /etc/fedora-release"
    rlRun "dnf -y install postgresql17-server"

    rlRun "autoreconf -vfi" 0 "Building and installing postgresql-setup"
    rlRun "./configure --prefix=/usr"
    rlRun "make"
    rlRun "./bin/postgresql-setup --init" 0 "Initializing database dir"
    rlRun "systemctl start postgresql" 0 "Starting service"
    rlRun "systemctl is-active postgresql" 0 "Verifying service running"
  rlPhaseEnd

  rlPhaseStartTest
    rlRun "su - postgres -c \"
    createdb testdb;
    psql -U postgres -d testdb -c \\\"create table users (id serial primary key, name text)\\\";
    psql -U postgres -d testdb -c \\\"insert into users (name) values ('Alice'), ('Bob'), ('Celine')\\\"
    \""
    rlRun "su - postgres -c '
    psql -U postgres -d testdb -c \"select * from users\"
    ' > expected.txt"

    echo "Expected:"
    cat expected.txt

    rlRun "dnf -y remove postgresql17*" 0 "Removing postgresql 17"
    rlRun "dnf -y install postgresql18-upgrade" 0 "Installing postgresql 18"

    rlRun "./bin/postgresql-setup --upgrade" 1 "Upgrading without checksums flags"
    rlRun "PGSETUP_INITDB_OPTIONS='--no-data-checksums' ./bin/postgresql-setup --upgrade --data-checksums" 0 "Upgrading with contradictory flags"

    rlRun "systemctl start postgresql" 0 "Starting service again"
    rlRun "systemctl is-active postgresql" 0 "Verifying service running"

    rlRun "su - postgres -c '
    psql -U postgres -d testdb -c \"select * from users\"
    ' > actual18.txt"

    echo "Actual:"
    cat actual18.txt

    rlAssertNotDiffer expected.txt actual18.txt
    rlRun "pg_checksums /var/lib/pgsql/data" 0 "Verify checksums enabled"
  rlPhaseEnd

  rlPhaseStartCleanup
    rlRun "popd"
    rlRun "rm -rf repo"
    rlRun "systemctl stop postgresql" 0 "Stopping postgresql service"
    rlRun "rm -rf /var/lib/pgsql" 0 "Removing database folder"
    rlRun "dnf -y remove postgresql*" 0 "Uninstalling postgresql"
  rlPhaseEnd
rlJournalPrintText
rlJournalEnd