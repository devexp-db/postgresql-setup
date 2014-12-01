#!/bin/sh
#
# Legacy action script for "service postgresql upgrade"

# Find the name of the service
SERVICE_NAME=$(basename $(dirname "$0"))
if [ x"$SERVICE_NAME" = x. ]
then
    SERVICE_NAME=postgresql
fi

echo Hint: the preferred way to do this is now '"postgresql-setup upgrade"' >&2

/usr/bin/postgresql-setup upgrade "$SERVICE_NAME"

exit $?
