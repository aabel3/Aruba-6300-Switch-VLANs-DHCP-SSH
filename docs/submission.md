# 📝 Project Summary

| | |
|---|---|
| **Project** | Aruba 6300 switch with two Ubuntu VMs |
| **Focus** | VLANs, inter-VLAN routing, DHCP and SSH |
| **Date** | May 2025 (documentation updated November 2026) |

---

## Overview

Two Ubuntu Linux virtual machines are connected to an Aruba 6300 switch. The switch assigns each VM an IP address and default gateway from its own DHCP pools, so the VMs communicate without relying on the campus network's addressing. The VMs and the switch are then reached over SSH.

## Goals

- Configure static addressing, VLANs and default gateways on the switch.
- Make sure both VMs connect without relying on the campus IP and gateway.
- Log in over SSH between the VMs, using key pairs generated with `ssh-keygen`.
- Demonstrate the working setup live and document it.

## Steps Followed

1. List the interfaces and MAC addresses on each VM with `ip -brief link`.
2. After confirming the Aruba network, edit `/etc/ssh/sshd_config` and set `PermitRootLogin no`.
3. Restart SSH and create a key pair with `ssh-keygen` for each user.
4. Copy the keys across and test with `ssh <username>@<ip address>`.

## Deliverables

| Deliverable | Location |
|-------------|----------|
| Network diagram | [`packet-tracer/network-diagram.pkt`](../packet-tracer/network-diagram.pkt), [`screenshots/01-network-diagram.png`](../screenshots/01-network-diagram.png) |
| Switch configuration script | [`configs/aruba-6300-switch.cfg`](../configs/aruba-6300-switch.cfg) |
| `sshd_config` change | [`configs/sshd_config.snippet`](../configs/sshd_config.snippet) |
| Wireshark SSH captures | `screenshots/02` – `05` |
| `ip a`, `ip route` on both VMs | `screenshots/06` – `09` |
| `sh ip int br`, `sh spanning-tree`, `show vlan`, `sh dhcp-server leases` | `screenshots/11` – `15` |

## Conclusion

Two Ubuntu systems were connected to an Aruba switch, assigned IP addressing and gateways through DHCP, and shown communicating with each other and with the switch over SSH, supported by Wireshark captures. The project gave hands-on practice with VLANs, DHCP, routing and SSH.

## References

- [ArubaOS 8.x CLI Reference Guide](https://arubanetworking.hpe.com/techdocs/ArubaOS-8.x-Books/ArubaOS-8.x-CLI-Reference-Guide.pdf)
- [HPE Support – document a00021327en_us](https://support.hpe.com/hpesc/public/docDisplay?docId=a00021327en_us)
- [HPE Support – document a00055715en_us](https://support.hpe.com/hpesc/public/docDisplay?docId=a00055715en_us&docLocale=en_US)
