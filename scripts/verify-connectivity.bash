#!/bin/bash
#
# verify-connectivity.bash
# Aruba 6300 VLANs, DHCP & SSH lab
#
# Runs the VM-side checks for the Aruba 6300 lab:
#   1. Interface address on ens37 (from the switch DHCP pool)
#   2. Routing table
#   3. Ping to the local gateway and to a peer on the other VLAN
#   4. SSH port reachability on the gateway and the peer
#
# Usage:  ./verify-connectivity.bash [gateway_ip] [peer_ip] [interface]
# Example: ./verify-connectivity.bash 172.16.7.1 172.16.70.9 ens37
#
# Written and tested by: Avraham Abel

GATEWAY="${1:-172.16.7.1}"
PEER="${2:-172.16.70.9}"
IFACE="${3:-ens37}"

# Welcome splash screen
printf '#%.0s' {1..50}; printf '\n'
printf '  Aruba 6300 Lab - Connectivity Check\n'
printf '#%.0s' {1..50}; printf '\n\n'

PASS=0
FAIL=0

check() {
    # check "description" command...
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then
        printf '[ OK ]   %s\n' "$desc"
        PASS=$((PASS + 1))
    else
        printf '[FAIL]   %s\n' "$desc" >&2
        FAIL=$((FAIL + 1))
    fi
}

# 1. Interface address
printf '== Interface %s ==\n' "$IFACE"
ip -brief addr show "$IFACE" 2>/dev/null || printf 'Interface %s not found\n' "$IFACE" >&2
printf '\n'

# 2. Routing table
printf '== Routes ==\n'
ip route
printf '\n'

# 3. Reachability
printf '== Checks ==\n'
check "Interface $IFACE has a 172.16.x.x address" \
    bash -c "ip -4 addr show '$IFACE' | grep -q 'inet 172\.16\.'"
check "Ping gateway $GATEWAY" ping -c 2 -W 2 "$GATEWAY"
check "Ping peer $PEER (other VLAN)" ping -c 2 -W 2 "$PEER"

# 4. SSH port
check "SSH port 22 open on $GATEWAY" timeout 3 bash -c "</dev/tcp/$GATEWAY/22"
check "SSH port 22 open on $PEER" timeout 3 bash -c "</dev/tcp/$PEER/22"

printf '\nResult: %d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
