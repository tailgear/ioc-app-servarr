#!/bin/sh

pw groupadd media -g 8675309
pw groupmod media -m lidarr
pw groupmod media -m radarr
pw groupmod media -m readarr
pw groupmod media -m sonarr
pw groupmod media -m prowlarr
pw groupmod media -m transmission

mkdir /media/data
chown root:media /media/data
chmod 775 /media/data

cd /usr/local

wget https://github.com/tailgear/homarr/archive/dev.zip
unzip dev.zip
rm dev.zip
mv homarr-dev homarr
cd homarr

npm i
npm run build
npm prune --production
npm i -g pm2

pm2 start npm --name Homarr -- start --prefix /usr/local/homarr/
pm2 save
mkdir /usr/local/etc/rc.d
pm2 startup rcd

# Enable the service
sysrc -f /etc/rc.conf lidarr_enable="YES"
sysrc -f /etc/rc.conf radarr_enable="YES"
sysrc -f /etc/rc.conf readarr_enable="YES"
sysrc -f /etc/rc.conf sonarr_enable="YES"
sysrc -f /etc/rc.conf prowlarr_enable="YES"
sysrc -f /etc/rc.conf transmission_enable="YES"
sysrc -f /etc/rc.conf transmission_download_dir="/media/data"

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