#!/usr/bin/env python3


def _to_volume_string(volume):
    mode = ""
    if volume["mode"]:
        mode = f":{volume['mode']}"
    return f"/mnt/{volume['name']}:{volume['dest']}{mode}"


def format_volumes(volumes):
    return [_to_volume_string(volume) for volume in volumes]


class FilterModule(object):
    def filters(self):
        return {
            "to_podman_volumes": format_volumes,
        }
