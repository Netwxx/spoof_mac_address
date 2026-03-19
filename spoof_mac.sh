#!/usr/bin/env bash
# spoof_mac.sh — temp MAC spoofing using verified vendor OUIs
# Usage: sudo ./spoof_mac.sh <interface>
# (Must be run by root/sudo)

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

# verified vendor OUIs
OUIS=(
  "dc:a6:32"  # Raspberry Pi
  "b8:27:eb"  # Raspberry Pi
  "d4:81:d7"  # Dell
  "8c:8d:28"  # Dell
  "3c:97:0e"  # Apple
  "f0:18:98"  # Apple
  "00:50:f2"  # Microsoft
  "fc:77:74"  # Samsung
  "40:b0:76"  # Intel
  "8c:f3:19"  # Intel
  "00:20:6b"  # Konica Minolta
  "d0:21:f9"  # Ubiquiti
)

# pick a random verified OUI and generate random last 3 octets
generate_mac() {
  local oui="${OUIS[$RANDOM % ${#OUIS[@]}]}"
  local suffix
  suffix=$(printf '%02x:%02x:%02x' \
    $((RANDOM % 256)) \
    $((RANDOM % 256)) \
    $((RANDOM % 256)))
  echo "$oui:$suffix"
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
echo "Vendor:      $(echo "$NEW_MAC" | cut -d: -f1-3) (${OUIS_NAMES[$RANDOM % ${#OUIS[@]}]:-verified vendor})"
echo "Current MAC for $IFACE: $CURRENT"