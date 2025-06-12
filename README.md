# postgresql-setup

## Requires

### BuildRequires
- m4
- docbook-utils
- help2man
- elinks (pretty README.rpm-dist)
- postgresql-server (detect current version)

### Requires
- coreutils

### Suggested BuildRequires
- util-linux (mountpoint utility)

### Maintainer's BuildRequires
- autoconf
- automake
- autoconf-archive

## Usage
This script is used as a wrapper around PostgreSQL initialization and upgrade
commands. It also parses init system service files and/or enviroment files to
correctly find datadir based on current system.

### Initialization
To initialize new PostgreSQL data directory use `./postgresql-setup --initdb`.

### Upgrade
To upgrade existing PostgreSQL data directory to use newer PostgreSQL version
use `./postgresql-setup --upgrade`.

If your distribution doesn't include this
script with PostgreSQL and you are using this on your own, please update
`etc/postgresql-setup/upgrade/postgresql.conf` to reflect your setup.

### Running without systemd/init system
Your setup might not include systemd as the init system or include any
init system at all. This would be the case in most of the base container images
for example. This script will try to compensate by parsing systemd
service file in preconfigured path directly. By default the path is
`/lib/systemd/system`.

If there is no systemd service file, or for whatever reason the script is unable
to find valid PostgreSQL data directory, you can still provide PostgreSQL data
directory path manually by using `--datadir` argument. For example when
initializing new data directory use `./postgresql-setup --initdb --datadir=/my/path`.

This feature is most beneficial when using this script inside container images,
as it gives you the most control with least dependencies.

## Maintainer notes
Be careful about paths. Your might need to tweak paths either in configure
  files, or in code based on your environment.
- Line 49 of `/bin/postgresql-setup` in function `builddir_source ()` has to
  be changed to location of your project otherwise you won't be able to run your
  build without full installation into system paths
    - For example line should be `. "/postgresql-setup/$file"` if your
      working project is located at `/postgresql-setup`
    - *Do NOT commit/merge this change*

### Build instructions
1. `autoreconf -vfi`
2. `./configure --prefix=/usr`
    - Prefix needed for fedora environment - one of the path tweaks that are needed
3. `make`

After aforementioned steps, you should be able to run freshly built
postgresql-setup script directly from /bin folder in this repo.

If no init system is present, PostgreSQL server can be run after initialization
via `/usr/bin/pg_ctl -D /var/lib/pgsql/data -l /var/lib/pgsql/logfile start`