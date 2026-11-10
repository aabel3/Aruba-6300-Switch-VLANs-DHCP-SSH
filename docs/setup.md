# ⚙️ Setup Guide

Step-by-step instructions to rebuild the Aruba 6300 VLANs, DHCP & SSH lab.

> Addressing and port assignments are in [topology.md](topology.md).

---

## 1. Configure the Aruba 6300 switch

1. Connect to the switch console or SSH in, then enter configuration mode:

   ```
   6300# configure terminal
   6300(config)#
   ```

2. Paste the contents of [`configs/aruba-6300-switch.cfg`](../configs/aruba-6300-switch.cfg). It creates:
   - DHCP pools `vlan7` and `vlan70`
   - VLANs 7 and 70
   - Gateway interfaces `interface vlan 7` (`172.16.7.1/26`) and `interface vlan 70` (`172.16.70.1/26`)
   - Access ports `1/1/1` (VLAN 7) and `1/1/2` (VLAN 70)

3. Confirm the interfaces are up:

   ```
   6300# sh ip int br
   vlan7             172.16.7.1/26         up/up
   vlan70            172.16.70.1/26        up/up
   ```

---

## 2. Connect the Ubuntu VMs

1. Give each VM two network adapters: one for the campus network (`ens33`) and one bridged to the NIC cabled to the switch (`ens37`).
2. Cable the VLAN 7 VM to switch port `1/1/1` and the VLAN 70 VM to port `1/1/2`.
3. List the interfaces and MAC addresses:

   ```bash
   ip -brief link
   ```

4. Check that `ens37` received an address from the switch:

   ```bash
   ip a
   ```

   Expected (VLAN 70 VM):

   ```
   inet 172.16.70.9/26 brd 172.16.70.63 scope global dynamic noprefixroute ens37
   ```

5. Check the default gateway and the route to the other VLAN:

   ```bash
   ip route
   ```

   If the other VLAN is missing, add a route through the local gateway (VLAN 70 VM shown):

   ```bash
   sudo ip route add 172.16.7.0/26 via 172.16.70.1 dev ens37
   ```

   > The project report does not show how the routes were added. This is the standard command for it; use your own method (for example Netplan) if you need it to persist across reboots.

---

## 3. Configure SSH on the VMs

1. Install the SSH server if it is not already present:

   ```bash
   sudo apt update
   sudo apt install -y openssh-server
   ```

2. Disable direct root login. Edit `/etc/ssh/sshd_config` (see [`configs/sshd_config.snippet`](../configs/sshd_config.snippet)):

   ```
   PermitRootLogin no
   ```

3. Restart the service:

   ```bash
   sudo systemctl restart ssh
   sudo systemctl status ssh
   ```

4. Create a key pair for the user on each VM:

   ```bash
   ssh-keygen
   ```

5. Copy the public key to the other VM:

   ```bash
   ssh-copy-id <username>@<other-vm-ip>
   ```

---

## 4. Test SSH and capture it in Wireshark

1. Start Wireshark on `ens37` and set the display filter to `ssh`.
2. From each VM, SSH to the other VM:

   ```bash
   ssh <username>@<other-vm-ip>
   ```

3. From each VM, SSH to the switch gateway:

   ```bash
   ssh student@172.16.7.1      # from the VLAN 7 VM
   ssh student@172.16.70.1     # from the VLAN 70 VM
   ```

4. Confirm Wireshark shows the SSHv2 version exchange, `Key Exchange Init` and `Elliptic Curve Diffie-Hellman Key Exchange Init` packets.

---

## 5. Verify the switch

Run the show commands listed in [verification.md](verification.md): `sh spanning-tree`, `show vlan` and `sh dhcp-server leases`.

---

## 🧯 Troubleshooting

- **VM has no `172.16.x.x` address** – check the port is up and in the right VLAN with `show vlan`, and that `dhcp-server` is `enable`d.
- **Cannot reach the other VLAN** – verify the static route with `ip route` and that both `interface vlan` SVIs are `up/up`.
- **SSH refuses the connection** – confirm `sudo systemctl status ssh` is running on the target VM.
