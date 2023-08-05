#!/bin/sh

mkdir /data
chmod 666 /data

# Enable the service
sysrc -f /etc/rc.conf lidarr_enable="YES"
sysrc -f /etc/rc.conf radarr_enable="YES"
sysrc -f /etc/rc.conf readarr_enable="YES"
sysrc -f /etc/rc.conf sonarr_enable="YES"
sysrc -f /etc/rc.conf prowlarr_enable="YES"
sysrc -f /etc/rc.conf transmission_enable="YES"
sysrc -f /etc/rc.conf transmission_download_dir="/data"

# Start the service
service lidarr start 2>/dev/null
service radarr start 2>/dev/null
service readarr start 2>/dev/null
service sonarr start 2>/dev/null
service prowlarr start 2>/dev/null
service transmission start 2>/dev/null
sleep 2 # It can take a few seconds.

# Without the whitelist disabled, the user will not be able to access it. They can reenable and manually whitelist their IP's.
SETTINGS="/usr/local/etc/transmission/home/settings.json"

echo "Disabling RPC whitelist, you may want to reenable it with the specific IP's you will access transmission with by editing $SETTINGS"
sed -i '' -e 's/\([[:space:]]*"rpc-whitelist-enabled":[[:space:]]*\)true,/\1false,/' $SETTINGS

service transmission reload