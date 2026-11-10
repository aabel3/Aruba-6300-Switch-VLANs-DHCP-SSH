# ✅ Verification

Each check below lists the command, the expected output (taken from the project screenshots) and the matching screenshot. All captures are from 16 May 2025.

---

## Ubuntu VMs

### `ip a` – address from the switch

```bash
ip a
```

VLAN 70 VM (hostname `ubuntuvm`):

```
3: ens37: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
    inet 172.16.70.9/26 brd 172.16.70.63 scope global dynamic noprefixroute ens37
```

VLAN 7 VM (hostname `csp450`):

```
3: ens37: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
    inet 172.16.7.37/26 brd 172.16.7.63 scope global dynamic noprefixroute ens37
```

Screenshots: [VLAN 70 VM](../screenshots/06-ip-a-vlan70-vm.png) · [VLAN 7 VM](../screenshots/07-ip-a-vlan7-vm.png)

### `ip route` – default gateway and route to the other VLAN

VLAN 70 VM:

```
default via 10.33.35.1 dev ens33 proto dhcp metric 100
default via 172.16.70.1 dev ens37 proto dhcp metric 20101
10.33.35.0/24 dev ens33 proto kernel scope link src 10.33.35.53 metric 100
169.254.0.0/16 dev ens37 scope link metric 1000
172.16.7.0/26 via 172.16.70.1 dev ens37
172.16.70.0/26 dev ens37 proto kernel scope link src 172.16.70.9 metric 101
```

VLAN 7 VM:

```
default via 10.33.35.1 dev ens33 proto dhcp metric 100
default via 172.16.7.1 dev ens37 proto dhcp metric 20101
10.33.35.0/24 dev ens33 proto kernel scope link src 10.33.35.62 metric 100
169.254.0.0/16 dev ens37 scope link metric 1000
172.16.7.0/26 dev ens37 proto kernel scope link src 172.16.7.37 metric 101
172.16.70.0/26 via 172.16.7.1 dev ens37
```

Screenshots: [VLAN 70 VM](../screenshots/08-ip-route-vlan70-vm.png) · [VLAN 7 VM](../screenshots/09-ip-route-vlan7-vm.png)

### `sshd_config` – root login disabled

```
PermitRootLogin no
```

Screenshot: [10-sshd-config.png](../screenshots/10-sshd-config.png)

---

## SSH Tests (Wireshark filter: `ssh`)

### VM to VM across the switch

```bash
ssh <username>@172.16.7.37      # from the VLAN 70 VM
ssh <username>@172.16.70.9      # from the VLAN 7 VM
```

Expected: an Ubuntu 22.04.5 LTS welcome banner and a shell prompt on the remote VM. Wireshark shows `SSHv2` packets between `172.16.70.9` and `172.16.7.37`: client and server protocol banners (`SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.13`) followed by `Key Exchange Init`.

Screenshots: [VLAN 7 → VLAN 70](../screenshots/04-ssh-vm-to-vm-vlan7-to-vlan70.png) · [VLAN 70 → VLAN 7](../screenshots/05-ssh-vm-to-vm-vlan70-to-vlan7.png)

### VM to switch

```bash
ssh student@172.16.70.1        # from the VLAN 70 VM
ssh student@172.16.7.1         # from the VLAN 7 VM
```

Expected: the HPE login banner, a password prompt, then the switch prompt:

```
student@172.16.7.1's password:
Last login: 2025-05-16 14:26:42 from 172.16.7.37
6300#
```

Wireshark shows the full handshake: protocol exchange, `Key Exchange Init`, `Elliptic Curve Diffie-Hellman Key Exchange Init`/`Reply`, `New Keys`, then encrypted packets.

Screenshots: [VLAN 70 VM](../screenshots/02-ssh-to-switch-vlan70-wireshark.png) · [VLAN 7 VM](../screenshots/03-ssh-to-switch-vlan7-wireshark.png)

---

## Aruba 6300 Switch

### `sh ip int br`

```
6300# sh ip int br
Interface         IP Address            Interface Status
                                        link/admin
vlan1             No Address            down/up
vlan7             172.16.7.1/26         up/up
vlan70            172.16.70.1/26        up/up
```

Screenshot: [11-show-ip-interface-brief.png](../screenshots/11-show-ip-interface-brief.png)

### `sh spanning-tree`

```
6300# sh spanning-tree
Spanning tree status      : Enabled Protocol: MSTP

MST0
  Root ID    Priority   : 32768
             MAC-Address: bc:d7:a5:d3:cd:80
             This bridge is the root

Port     Role         State       Cost    Priority  Type
1/1/1    Designated   Forwarding  20000   128       P2P
1/1/2    Designated   Forwarding  20000   128       P2P
1/1/3    Disabled     Blocking    20000   128       P2P
...
```

Screenshots: [part 1](../screenshots/12-show-spanning-tree-part1.png) · [part 2](../screenshots/13-show-spanning-tree-part2.png)

### `show vlan`

```
6300# show vlan
VLAN  Name             Status  Reason                Type     Interfaces
1     DEFAULT_VLAN_1   down    no_member_forwarding  default  1/1/3-1/1/24,1/1/27-1/1/28
7     VLAN7            up      ok                    static   1/1/1
70    VLAN70           up      ok                    static   1/1/2
```

Screenshot: [14-show-vlan.png](../screenshots/14-show-vlan.png)

### `sh dhcp-server leases`

```
6300# sh dhcp-server leases
IP-Address      Client-Hostname     VRF-Name
172.16.7.30     NHK1270-19-E063     default
172.16.7.37     csp450              default
172.16.70.9     ubuntuvm            default
172.16.70.48    NHK1270-20-E1C2     default
```

Screenshot: [15-show-dhcp-server-leases.png](../screenshots/15-show-dhcp-server-leases.png)

---

## Optional: scripted VM-side checks

[`scripts/verify-connectivity.bash`](../scripts/verify-connectivity.bash) runs the address, route, ping and SSH-port checks from a VM in one go:

```bash
./scripts/verify-connectivity.bash 172.16.7.1 172.16.70.9
```
