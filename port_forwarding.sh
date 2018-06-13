#!/usr/bin/env bash
# Source: http://www.htpcguides.com
# Adapted from https://github.com/blindpet/piavpn-portforward/
# Author: Mike
# Based on https://github.com/crapos/piavpn-portforward

# Set path for root Cron Job
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

USERNAME=p8537014
PASSWORD=P4FA9grgw6
VPNINTERFACE=tun0
VPNLOCALIP=$(ifconfig $VPNINTERFACE | awk '/inet / {print $2}' | awk 'BEGIN { FS = ":" } {print $(NF)}')
CURL_TIMEOUT=10
CLIENT_ID=$(uname -v | sha1sum | awk '{ print $1 }')

# set to 1 if using VPN Split Tunnel
SPLITVPN="1"

#get VPNIP
VPNIP=$(sudo -u vpn -i -- curl "http://ipinfo.io/ip" --silent --stderr -)
echo "IP VPN : $VPNIP"

#request new port
PORTFORWARDJSON=$(sudo -u vpn -i -- curl -m $CURL_TIMEOUT --silent 'https://www.privateinternetaccess.com/vpninfo/port_forward_assignment' -d "user=$USERNAME&pass=$PASSWORD&client_id=$CLIENT_ID&local_ip=$VPNLOCALIP" | head -1)
echo "réponse PIA : $PORTFORWARDJSON"

#trim VPN forwarded port from JSON
PORT=$(echo $PORTFORWARDJSON | awk 'BEGIN{r=1;FS="{|:|}"} /port/{r=0; print $3} END{exit r}')
echo "Port : $PORT"

#change firewall rules if SPLITVPN is set to 1
if [ "$SPLITVPN" -eq "1" ]; then
    #change firewall rules if necessary
    IPTABLERULETWO=$(sudo iptables -L INPUT -n --line-numbers | grep -E "2.*reject-with icmp-port-unreachable" | awk '{ print $8 }')
    if [ -z $IPTABLERULETWO ]; then
        sudo iptables -D INPUT 2
        sudo iptables -I INPUT 2 -i $VPNINTERFACE -p tcp --dport $PORT -j ACCEPT
    else
        sudo iptables -I INPUT 2 -i $VPNINTERFACE -p tcp --dport $PORT -j ACCEPT
    fi
fi

#change transmission port on the fly
transmission-remote -p $PORT
