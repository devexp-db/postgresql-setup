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
    rlRun "dnf -y install postgresql16-server"

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

    # change locale (https://wiki.archlinux.org/title/Locale#Make_locale_changes_immediate)
    rlRun "localectl set-locale LANG=en_GB.UTF-8" 0 "Changing locale"
    rlRun "unset LANG"
    rlRun "source /etc/profile.d/lang.sh"
    rlRun "locale"

    rlRun "dnf -y remove postgresql16*" 0 "Removing postgresql 16"
    rlRun "dnf -y install postgresql17-upgrade" 0 "Installing postgresql 17"
    rlRun "./bin/postgresql-setup --upgrade" 0 "Running upgrade"

    rlRun "systemctl start postgresql" 0 "Starting service again"
    rlRun "systemctl is-active postgresql" 0 "Verifying service running"

    rlRun "su - postgres -c '
    psql -U postgres -d testdb -c \"select * from users\"
    ' > actual17.txt"

    echo "Actual:"
    cat actual17.txt

    rlAssertNotDiffer expected.txt actual17.txt

    rlRun "localectl set-locale LC_COLLATE=en_US.UTF-8" 0 "Changing LC_COLLATE"
    rlRun "localectl set-locale LC_CTYPE=en_AU.UTF-8" 0 "Changing LC_CTYPE"
    rlRun "unset LANG"
    rlRun "source /etc/profile.d/lang.sh"
    rlRun "locale"

    rlRun "dnf -y remove postgresql17*" 0 "Removing postgresql 17"
    rlRun "dnf -y install postgresql18-upgrade" 0 "Installing postgresql 18"
    # TODO: remove if functionality added to the script
    rlRun "/usr/lib64/pgsql/postgresql-17/bin/pg_checksums -e /var/lib/pgsql/data" 0 "Enabling data checksums for pg18"

    rlRun "su - postgres -c '/usr/lib64/pgsql/postgresql-17/bin/pg_ctl -D /var/lib/pgsql/data -l /var/lib/pgsql/logfile start'" 0 "Starting postgres pre-upgrade"
    rlRun "su - postgres -c '/usr/lib64/pgsql/postgresql-17/bin/pg_ctl -D /var/lib/pgsql/data status'" 0 "Verifying postgres is running"

    rlRun "./bin/postgresql-setup --upgrade --debug" 1 "Trying to run upgrade"
    rlRun "su - postgres -c '/usr/lib64/pgsql/postgresql-17/bin/pg_ctl -D /var/lib/pgsql/data stop'" 0 "Stopping old postgres"
    rlRun "./bin/postgresql-setup --upgrade --debug" 0 "Upgrading"

    rlRun "systemctl start postgresql" 0 "Starting service again"
    rlRun "systemctl is-active postgresql" 0 "Verifying service running"

    rlRun "su - postgres -c '
    psql -U postgres -d testdb -c \"select * from users\"
    ' > actual18.txt"

    echo "Actual:"
    cat actual18.txt

    rlAssertNotDiffer actual17.txt actual18.txt
  rlPhaseEnd

  rlPhaseStartCleanup
    rlRun "popd"
    rlRun "rm -rf repo"
    rlRun "echo 'LANG=en_US.UTF-8' > /etc/locale.conf" 0 "Resetting locale"
    rlRun "unset LANG"
    rlRun "source /etc/profile.d/lang.sh"
    rlRun "systemctl stop postgresql" 0 "Stopping postgresql service"
    rlRun "rm -rf /var/lib/pgsql" 0 "Removing database folder"
    rlRun "dnf -y remove postgresql*" 0 "Uninstalling postgresql"
  rlPhaseEnd
rlJournalPrintText
rlJournalEnd
