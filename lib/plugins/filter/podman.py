#!/usr/bin/env python3


def _to_volume_string(volume):
    mode = ""
    if volume.get("mount_mode"):
        mode = f":{volume['mount_mode']}"

    host_src = f"/mnt/{volume['name']}"
    if volume.get("host_src"):
        host_src = volume["host_src"]

    return f"{host_src}:{volume['dest']}{mode}"


def format_volumes(volumes):
    return [_to_volume_string(volume) for volume in volumes]


class FilterModule(object):
    def filters(self):
        return {
            "to_podman_volumes": format_volumes,
        }
