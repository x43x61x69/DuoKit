opkg update
opkg install wget ca-certificates
wget --no-check-certificate -O /etc/avahi/services/duokit.service https://raw.githubusercontent.com/x43x61x69/DuoKit/master/misc/avahi-service/duokit.service
uci set yunbridge.config.disabled='0'
uci commit
reboot
