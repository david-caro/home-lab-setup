This directory contains some custom images that I needed to make the cephadm
setup work on RaspberryPi 4, with Debian 11 arm64.

These images are pushed to `quay.io`, so you'll need an account and set it up
before pushing anything there.


ceph_aarch64
------------
This is an image of ceph with a couple changes:
* Use a newer rocksdb that fixes an issue with PMULL:
    https://github.com/ceph/ceph/pull/41079
* Make ceph-volume consider /dev/root as mounted.


Build
#####
Install `podman` and `buildah`, and from the `ceph_aarch64` folder run:
```
# you can change the image tag to whatever you need.
> buildah bud quay.io/dcaro/ceph:v16.2.1_with_aarch64_fixes .
```

Push
####
Just:
```
> podman push quay.io/dcaro/ceph:v16.2.1_with_aarch64_fixes
```

Usage
#####
Then you can change the `cephadm_image` from the `group_vars/all.yaml` file to
that new image tag (if you changed it).
