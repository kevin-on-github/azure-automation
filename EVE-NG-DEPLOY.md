## How to deploy EVE-NG in MS Azure.

### Get the script.
 - First download the [az-cli-script.sh](https://raw.githubusercontent.com/kevin-on-github/azure-automation/main/az-cli-script.sh)
 - Open a terminal to the location of the file, and... \
 `chmod +x az-cli-script.sh`
 - Execute the script, and fill in the info. \
  `./az-cli-script.sh`

### SSH to the new VM and enable root login from SSH. Necessary for the setup of EVE-NG, can disable after setup.
 - `sudo passwd root` and set a complex password.
 - `sudo nano /etc/ssh/sshd_config`
     - Find "PermitRootLogin prohibit-password" and comment it out. \
     `# PermitRootLogin prohibit-password`
     - Under that commented entry create a new line with \
     `PermitRootLogin yes` \
     - Save and close.
     - Back at the terminal run \
      `sudo service ssh restart`
 - Logout your admin user account, and login as root to test access.

### SSH to the new VM as 'root' and update a few params.
 - Copy and past this into a root terminal. \
  `sed -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="net.ifnames=0 noquiet"/' /etc/default/grub` \
  `update-grub`
 - update hostname and hosts file \
     `nano /etc/hosts` \
     `127.0.0.1 eve-ng-vm.eve-ng.net eve-ng-vm` \
     `nano /etc/hostname` \
     `eve-ng-vm`
 - update the network interface names to prep for eve-ng install \
     `nano /etc/network/interfaces` \
         - Locate the ethernet name and change to 'eth0'. If nto listed, just add it. \
         `auto eth0` \
         `iface eth0 inet dhcp`
 - REBOOT             


### Pull the EVE-NG install script, and pipe to bash
  `wget -O - http://www.eve-ng.net/repo/install-eve.sh | bash -i`


### Azure VMs do not allow for a promiscuous NIC, so we will instead create a private switch on Cloud1 (pnet1) and use iptables to masquerade the lab environment.
 `nano /etc/network/interfaces`
 - Locate pnet1 and make appropriate changes. I've chosen an RFC1918 class C network, but you choose whatever is appropriate. \
        `auto pnet1` \
        `iface pnet1 inet static` \
        `address 192.168.1.1` \
        `netmask 255.255.255.0` \
        `bridge_ports eth1` \
        `bridge_stp off`

- Enable ip forwarding \
  `echo 1 > /proc/sys/net/ipv4/ip_forward`
- Edit /etc/sysctl.conf to make it persistent across reboots. \
    `nano /etc/sysctl.conf` \
    - Find the section for packet forwarding and remove the comment. \
    ` # Uncomment the next line to enable packet forwarding for IPv4` \
    `net.ipv4.ip_forward=1`

 - Now will add a MASQUERADE for the new private subnet out the VMs NIC. Change  the subnet to whatever you assigned to pnet1 above.
    `iptables -t nat -A POSTROUTING -o pnet0 -s 192.168.1.0/24 -j MASQUERADE`

 - Install this package to keep the settings across reboots. \
    `apt-get install iptables-persistent`
 - Then save and reload the rules. \
    `netfilter-persistent save` \
    `netfilter-persistent reload`

 - Update and upgrade. \
    `apt-get update && apt-get upgrade -y`

 - Congradulations, EVE-NG is now setup in Azure. Open the website by typing in your Azure VMs dns name or public IP address. Make sure you login with Admin / eve and immediately change your password to something secure. By default EVE-NG does not have an SSL certificate. That's beyond this walkthrough, so happy labbing.

  - Once logged in, you will see that the only item you can add is the VPC. That's because you have to pay money to Cisco to get their VIRL/CML Images. There are some images available for free on the Interwebz, but that's beyond the scope of this tutorial.