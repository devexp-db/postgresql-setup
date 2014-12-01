#!/bin/sh
#
# Legacy action script for "service postgresql initdb"

# Find the name of the service
SERVICE_NAME=$(basename $(dirname "$0"))
if [ x"$SERVICE_NAME" = x. ]
then
    SERVICE_NAME=postgresql
fi

echo Hint: the preferred way to do this is now '"postgresql-setup initdb"' >&2

/usr/bin/postgresql-setup initdb "$SERVICE_NAME"

exit $?
