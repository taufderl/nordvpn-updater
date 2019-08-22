#!/bin/sh
# Get new configs, extract and patch

DATE=$(date +%Y%m%d)
CONFIG_DIR="./nordvpn/"
TEMP_DIR="/tmp/nordvpn_$DATE/"
mkdir -p $CONFIG_DIR

echo "[+] Downloading latest configuration files"
wget --quiet https://nordvpn.com/api/files/zip -O "/tmp/nordvpn_$DATE.zip"
unzip -q "/tmp/nordvpn_$DATE.zip" -d "/tmp/nordvpn_$DATE"

echo "[+] Patching config files"
sed -i "s/auth-user-pass/auth-user-pass .auth/g" $TEMP_DIR/*.ovpn

# Fix resolved
for f in $(ls "$TEMP_DIR"*.ovpn); do echo 'script-security 2' >> $f; done
for f in $(ls "$TEMP_DIR"*.ovpn); do echo 'up /etc/openvpn/update-systemd-resolved' >> $f; done
for f in $(ls "$TEMP_DIR"*.ovpn); do echo 'down /etc/openvpn/update-systemd-resolved' >> $f; done
for f in $(ls "$TEMP_DIR"*.ovpn); do echo 'down-pre' >> $f; done

echo "[+] Replacing old config files and cleaning up"
rm -rf $CONFIG_DIR*.ovpn
mv $TEMP_DIR*.ovpn $CONFIG_DIR
rm /tmp/nordvpn_$DATE.zip
rm -rf $TEMP_DIR

echo '[+] Done'
