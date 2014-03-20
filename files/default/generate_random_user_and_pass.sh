#!/bin/bash

#
# Script to generate random username, password, and hash
#

OID="$1";
echo ;

if [[ "$OID" == "" ]]; then
	echo "USAGE: ./generate_random_user_and_pass.sh [oid]";
	echo ;
	exit 1;
fi

# Random 4 digits
#
RANDFOUR=`tr -dc 0-9 < /dev/urandom | head -c 4`;
NEWUSER="$OID$RANDFOUR";

# Random password
#
RANDPASS=`tr -dc A-Za-z0-9 < /dev/urandom | head -c 12`;

# Random salt
#
RANDSALT=`tr -dc A-Za-z0-9 < /dev/urandom | head -c 8`;

# Password hash
HASH=`mkpasswd -m sha-512 $RANDPASS $RANDSALT`;

echo "Your credentials are:";
echo "  Username : $NEWUSER";
echo "  Password : $RANDPASS";
echo "  Hash : $HASH";
echo ;


exit;

