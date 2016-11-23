#!/bin/sh

# {{ ansible_managed }}

template=`cat <<TEMPLATE
***** Icinga  *****

Notification Type: $NOTIFICATIONTYPE

Service: $SERVICEDESC
Host: $HOSTALIAS
Address: $HOSTADDRESS
State: $SERVICESTATE

Date/Time: $LONGDATETIME

Additional Info: $SERVICEOUTPUT

Comment: [$NOTIFICATIONAUTHORNAME] $NOTIFICATIONCOMMENT
TEMPLATE
`

/usr/bin/printf "%b" "$template" | mail -s "$NOTIFICATIONTYPE - $HOSTDISPLAYNAME - $SERVICEDISPLAYNAME is $SERVICESTATE" $USEREMAIL

case $SERVICESTATE in
	CRITICAL)
	  COLOR="#F56";;
	OK)
	  COLOR="#4B7";;
	DOWN)
	  COLOR="#F56";;
	UP)
	  COLOR="#4B7";;
	WARNING)
	  COLOR="#FF6600";;
	*)
	  COLOR="#0095BF";;
esac
