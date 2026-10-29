# home-lab-setup
Scripts and code to setup and maintain my home lab

# Install
## Install the basic OS
Download the latest Raspberry Pi OS arm64 Lite image:
https://www.raspberrypi.org/software/operating-systems/

unzip, and burn into the new raspberry sdcard, ex:
```
> unzip 2021-03-04-raspios-buster-arm64-lite.zip

# check what is the device for the sd card
> lsblk -p

# in my laptop is usually
> SDCARD_DEV=/dev/mmcblk0

# burn it to the card, the sync is to make sure caches are flushed
> sudo dd if=2021-03-04-raspios-buster-arm64-lite.img of=$SDCARD_DEV bs=4M conv=fsync status=progress && sync
```

Now insert the card in the raspberry pi, and plug in:
* a monitor
* a keyboard
* a network cable to the router network

then turn it on, we are going to setup ssh so we can do everything else
remotely.

## Install the users
Once the rpi boots up and gives you login:
```
login: pi
password: raspberry
> sudo systemctl enable ssh
> sudo systemctl start ssh
```

You'll need ansible to follow the next steps. On CentOs based systems you can
install it by running the following command as root:
```
> sudo dnf install ansible
```

You might also want to install ansible-collection-ansible-posix.noarch if it's
not already installed. It's used for setting up ssh keys (in setup_users tasks).

```
> sudo dnf install ansible-collection-ansible-posix.noarch
```

And you will need also some galaxy modules:
```
> ansible-galaxy collection install containers.podman
```

Then you'll have to run the setup pi using the playbook, first add the new host
to the inventory, first to the `raspberries` group, with the current ip of the
server, and then to the `cluster`:
```
# inventory.ini
[raspberries]
...
node1 ansible_host=192.168.1.21
node2 ansible_host=192.168.1.22
+ node3 ansible_host=192.168.1.187

[cluster]
node1
node2
+ node3

```

Now we need to add a new host var file under `host_vars/node3.yaml` with the
desired ip:
```
# host_vars/node3.yaml
---
desired_ipaddress: 192.168.1.23
```


The first time, the system only has th `pi` user, and the following expects
that user to exist with the default password (then the user is deleted):
```
> ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook plays/one-shot/setup-raspberry-01.yaml
```

The skipping of host key checking is needed the first time otherwise ansible
will refuse to ssh to the new node (if you are replacing a node, you might need
to remove the old ssh key from your `known_hosts` file).

That will setup the users and ssh keys, then you have to run the second
playbook (in a different play as it uses a different user now):
```
> ansible-playbook plays/one-shot/setup-raspberry-02.yaml
```

That will update the hosts file on all the nodes, change some kernel setting,
and finish up the basic installation.


### Refresh your laptop settings
Now that we have the host set properly, we can update the inventory with the
correct ip, and update our laptop hosts settings:

Changes the `inventory.ini` file:
```
[raspberries]
...
node1 ansible_host=192.168.1.21
node2 ansible_host=192.168.1.22
- node3 ansible_host=192.168.1.187
+ node3 ansible_host=192.168.1.23
```

Run the laptop setup playbook, needs sudo to change the `/etc/hosts` file, so
pass the `-K` flag to prompt for it:
```
> ansible-playbook plays/one-shot/setup-laptop-01.yaml -K
```
