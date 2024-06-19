#!/bin/bash
set -e

# Load main settings
cat /default_config/settings.sh
. /default_config/settings.sh
cat /config/settings.sh
. /config/settings.sh

VXLAN_GATEWAY_IP="${VXLAN_IP_NETWORK}.1"
VXLAN_GATEWAY_IPv6="${VXLAN_IPV6_NETWORK}::1"

# Loop to test connection to gateway each 10 seconds
# If connection fails then reset connection
while true; do
  echo "Monitor connection to $VXLAN_GATEWAY_IP and $VXLAN_GATEWAY_IPv6"

  IPV4_CONNECTED=false
  IPV6_CONNECTED=false

  # Ping the gateway vxlan IP -> this only works when vxlan is up
  if ping -c "${CONNECTION_RETRY_COUNT}" "$VXLAN_GATEWAY_IP" > /dev/null; then
    IPV4_CONNECTED=true
  fi

  if ping6 -c "${CONNECTION_RETRY_COUNT}" "$VXLAN_GATEWAY_IPv6" > /dev/null; then
    IPV6_CONNECTED=true
  fi

  if $IPV4_CONNECTED && $IPV6_CONNECTED; then
    # Sleep while reacting to signals
    sleep 10 &
    wait $!
  else
    echo
    echo "IPv4=$IPV4_CONNECTED IPv6=$IPV6_CONNECTED"
    echo "Reconnecting to ${GATEWAY_NAME}"

    # reconnect
    client_init.sh
  fi
done
