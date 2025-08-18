#!/bin/bash


# Network interface to spoof, e.g. wlan0, enp3s0
INTERFACE="wlan0"


# Bring the interface down
sudo ip link set dev $INTERFACE down


# Generate a random locally administered unicast MAC address
# Format: 02:xx:xx:xx:xx:xx where 02 means locally administered unicast
NEW_MAC="02:$(openssl rand -hex 5 | sed 's/\(..\)/\1:/g; s/:$//')"


# Set the new MAC Address
sudo ip link set dev $INTERFACE address $NEW_MAC


# Bring the interface back up
sudo ip link set dev $INTERFACE up


echo "MAC address has been changed to $NEW_MAC on $INTERFACE"
