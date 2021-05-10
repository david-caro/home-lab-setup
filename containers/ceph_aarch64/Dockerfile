FROM docker.io/ceph/ceph:v16.2.1
COPY ceph.repo /etc/yum.repos.d/ceph.repo
RUN dnf upgrade --allowerasing -y && dnf clean all
COPY ceph_volume/util/system.py /usr/lib/python3.6/site-packages/ceph_volume/util/system.py
