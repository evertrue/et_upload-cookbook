#!/bin/bash

#
# Script to provision an upload server user
#
# 1) Creates new user
# 2) Assigns random password
# 3) Sets up directories
# 4) Modifies this user to have a restricted shell
#

OID="$1";
echo ;

if [[ "$OID" == "" ]]; then
	echo "USAGE: ./provision_upload_user.sh [oid]";
	echo ;
	exit 1;
fi

USER=`whoami`;
echo "whoami: $USER" >> /tmp/node_installer.out
if [ "$USER" != "root" ]; then
	echo "Must run as root"
	echo ;
	exit;
fi

# Random 4 digits
#
RANDFOUR=`tr -dc 0-9 < /dev/urandom | head -c 4`;
NEWUSER="$OID$RANDFOUR";

# Random password
#
RANDPASS=`tr -dc A-Za-z0-9 < /dev/urandom | head -c 12`;

echo "Creating new user $NEWUSER...";
useradd $NEWUSER;
echo ;

echo "Changing password for $NEWUSER to $RANDPASS";
echo $RANDPASS | passwd --stdin $NEWUSER;
echo ;

echo "Creating /home/$NEWUSER/.ssh/";
mkdir /home/$NEWUSER/.ssh;
chown -R $NEWUSER:$NEWUSER /home/$NEWUSER/.ssh/;
chmod 700 /home/$NEWUSER/.ssh/;
echo ;

echo "Creating /home/$NEWUSER/uploads/";
mkdir /home/$NEWUSER/uploads;
chown -R $NEWUSER:$NEWUSER /home/$NEWUSER/uploads/;
chmod 700 /home/$NEWUSER/uploads/;
echo ;

echo "Updating shell to rssh";
usermod -s /usr/local/bin/rssh $NEWUSER;
echo ;

echo "Running a test SCP, please enter password when prompted...";
scp testfile.txt $NEWUSER@upload.evertrue.com:/home/$NEWUSER/uploads/test.txt;
echo ;

echo "Testing for existence of /home/$NEWUSER/uploads/test.txt..."
if [ -e /home/$NEWUSER/uploads/test.txt ]; then
	echo "FOUND!"
	echo ;
else
	echo "Unable to verify file... ABORT!"
	echo ;
	exit;
fi

echo "Cleaning up...";
rm -f /home/$NEWUSER/uploads/*;
rm -f /home/$NEWUSER/.bash*;
rm -f /home/$NEWUSER/.kshrc*;
echo ;

echo "DONEZO... Cut & Paste:"
echo ;

echo "Your credentials are:";
echo "  Server   : upload.evertrue.com";
echo "  Username : $NEWUSER";
echo "  Password : $RANDPASS";
echo ;


exit;

