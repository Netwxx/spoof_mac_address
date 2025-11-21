#!/usr/bin/env bash
# ip-spoof-mac.sh — simple temp MAC spoofing using ip only
# Usage: sudo ./ip-spoof-mac.sh <interface>

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: sudo $0 <interface>"
  exit 1
fi

IFACE="$1"

# require root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

# check interface exists
if ! ip link show "$IFACE" >/dev/null 2>&1; then
  echo "Interface '$IFACE' not found. Run 'ip link' to list interfaces."
  exit 1
fi

# generate random locally-administered unicast MAC
generate_mac() {
  # first octet: clear multicast bit (LSB) and set locally-administered bit (second LSB)
  # compute first byte accordingly, then produce remaining 5 random bytes
  b0=$(( (RANDOM % 256 & 0xFC) | 0x02 ))
  printf "%02x:%02x:%02x:%02x:%02x:%02x" \
    "$b0" \
    $((RANDOM % 256)) \
    $((RANDOM % 256)) \
    $((RANDOM % 256)) \
    $((RANDOM % 256)) \
    $((RANDOM % 256))
}

NEW_MAC="$(generate_mac)"

echo "Changing $IFACE MAC -> $NEW_MAC (temporary; reboot restores hardware MAC)"

# apply with ip
ip link set dev "$IFACE" down
sleep 1
ip link set dev "$IFACE" address "$NEW_MAC"
sleep 1
ip link set dev "$IFACE" up

# report
CURRENT="$(cat /sys/class/net/"$IFACE"/address 2>/dev/null || true)"
echo "Current MAC for $IFACE: $CURRENT"
