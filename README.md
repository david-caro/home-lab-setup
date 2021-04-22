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
> dnf install ansible-collection-ansible-posix.noarch
```

Then you'll have to run the setup pi using the playbook, first add the new host
to the inventory:

If it's an k3s agent:
```
# inventory.yml
...
  cluster:
    children:
      ...
      agents:
        hosts:
          node2:
            ansible_host: 192.168.1.22
            ipaddress: 192.168.1.22
            # needed as raspberry os currently uses python2 by default
            ansible_python_interpreter: /usr/bin/python3
            hostname: node2
+         node3:
+           ansible_host: 192.168.1.153
+           ipaddress: 192.168.1.23
+           # needed as raspberry os currently uses python2 by default
+           ansible_python_interpreter: /usr/bin/python3
+           hostname: node3
```

If it's one of the k3s servers (remember that they should be an odd number):
```
# inventory.yml
...
  cluster:
    children:
      servers:
        hosts:
+         node1:
+           ansible_host: 192.168.1.212
+           ipaddress: 192.168.1.21
+           # needed as raspberry os currently uses python2 by default
+           ansible_python_interpreter: /usr/bin/python3
+           hostname: node2
```

For all, this requires the `pi` user to exist with the default password,
so it can only be run once (then the user is deleted):
```
> ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yml plays/setup-raspberry-01.yml
```

The skipping of host key checking is needed the first time otherwise ansible
will refuse to ssh to the new node (if you are replacing a node, you might need
to remove the old ssh key from your `known_hosts` file).

That will setup the users and ssh keys, then you have to run the second
playbook (in a different play as it uses a different user now):
```
> ansible-playbook -i inventory.yml plays/setup-raspberry-02.yml
```

That will update the hosts file on all the nodes, change some kernel setting,
and finish up the basic installation.

#### Upgrading to Debian 11
As we want Debian 11, we have to upgrade (until the Raspberry OS images are
out), for that you havet to run setup 03, that might take a while though, so
prepare some coffe or something:
```
> ansible-playbook -i inventory.yml setup-laptop-03.yml
```


### Refresh your laptop settings
Now that we have the host set properly, we can update the inventory with the
correct ip, and update our laptop hosts settings:

Changes the `inventory.yml` file:
```
       node3:
-           ansible_host: 192.168.1.153
+           ansible_host: 192.168.1.23
           ipaddress: 192.168.1.23
           # needed as raspberry os currently uses python2 by default
           ansible_python_interpreter: /usr/bin/python3
           hostname: node3
```

Run the laptop setup playbook, needs sudo to change the `/etc/hosts` file, so
pass the `-K` flag to prompt for it:
```
> ansible-playbook -i inventory.yml plays/setup-laptop-01.yml -K
```

## Install k3s
Just run the playbook:
```
> ansible-playbook -i inventory.yml plays/install-k3s.yml
```

If you installed the server, you'll have to run the second part too, to get
kubectl and the config from the server host:
```
> ansible-playbook -i inventory.yml setup-laptop-02.yml
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


## Preparing to install ceph

In order to install ceph (using cephadmin), we need to make sure 
