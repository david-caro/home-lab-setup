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

## Install the users, and preparation for k3s
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
server, and then to the `cluster` and `k3servers` groups:

If it's an k3s agent:
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

[k3servers]
# there should be an odd number of hosts in this group
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


#### Upgrading to Debian 11
As we want Debian 11 on the k3s nodes, we have to upgrade (until the Raspberry
OS images are out), for that you havet to run setup 03, that might take a
while though, so prepare some coffe or something:
```
> ansible-playbook plays/one-shot/setup-laptop-03.yaml
```

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

## Install k3s
__NOTE__: this is still not working along with ceph, current setup prefers CEPH
overs k3s so we installed CEPH only.
Just run the playbook:
```
> ansible-playbook plays/one-shot/install-k3s.yaml
```

If you installed the server, you'll have to run the second part too, to get
kubectl and the config from the server host:
```
> ansible-playbook plays/one-shot/setup-laptop-02.yaml
```

### Test that everything went ok

You can now run, from your laptop:
```
> kubectl get pods --all-namespaces
```

And you should see a bunch of pods around :), you can check the cluster status
with:
```
> kubectl cluster-info
```

## Install CEPH
There's a few issues that we had to deal with when installing CEPH.
Current setup uses cephadm with a custom image with all the bugs fixed/applied
(until they are released/backported upstream).


Just run the playbook:
```
> ansible-playbook plays/one-shot/install-ceph.yaml
```

That should trigger the whole installation setup, that cephadm will take over.
It usually takes a few minutes for everything to get setup (pulling images,
starting containers...), to check the progress you can login to one of the
nodes and run:
```
node1> sudo cephadm shell -- ceph orch ps
```
And/or:
```
node1> sudo cephadm shell -- ceph orch ls
```
