# home-lab-setup
Scripts and code to setup and maintain my home lab


## Installing a raspberry pi from scratch

Download the latest Raspberry Pi OS Lite image:
https://www.raspberrypi.org/software/operating-systems/

unzip, and burn into the new raspberry sdcard, ex:
```
> unzip 2021-03-04-raspios-buster-armhf-lite.zip

# check what is the device for the sd card
> lsblk -p

# in my laptop is usually
> SDCARD_DEV=/dev/mmcblk0

# burn it to the card
> dd if=2021-03-04-raspios-buster-armhf-lite.img of=$SDCARD_DEV conv=fsync
```

Now insert the card in the raspberry pi, and plug in:
* a monitor
* a keyboard
* a network cable to the router network

then turn it on, we are going to setup ssh so we can do everything else
remotely.

Once the rpi boots up and gives you login:
```
login: pi
password: raspberry
> sudo systemctl enable ssh
> sudo systemctl start ssh
```

Then you'll have to run the setup pi using the playbook, first add the new host
to the inventory:

```
# inventory.yml
...
            cluster1:
              ansible_host: 192.168.1.21
              # needed as raspberry os currently uses python2 by default
              ansible_python_interpreter: /usr/bin/python3
+            cluster2:
+              ansible_host: 192.168.1.22
+              # needed as raspberry os currently uses python2 by default
+              ansible_python_interpreter: /usr/bin/python3
```

And apply it:
```
> ansible-palybook -i inventory.yml setup-raspberry.yml
```

That will setup the users and cleanup some of the default stuff.
