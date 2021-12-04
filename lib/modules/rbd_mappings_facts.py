#!/usr/bin/env python3
from ansible.module_utils.basic import AnsibleModule
import json


DOCUMENTATION = r"""
---
module: rbd_mappings_facts

short_description: Gathers facts about rbd mapped devices

version_added: "1.0.0"

description: |>
    Checks the current mapped rbd modules and the devices they are mapped too
    and adds facts describing those.

author:
    - David Caro <david@dcaro.es>
"""

EXAMPLES = r"""
- name: "Refresh rbd mapped volumes"
  rbd_mappings_facts:
"""

RETURN = r"""
ansible_facts:
  description: Rbd mapped devices and info
  returned: always
  type: dict
  contains:
    id:
      description: Id of the rbd mapped device
      type: str
      returned: 
      sample: 'bar'
    answer:
      description:
      - Answer facts about operating system.
      - This description can be a list as well.
      type: str
      returned: when operating system answer fact is present
      sample: '42'
"""


def run_module():
    module_args = {}

    result = {
        "changed": False,
        "ansible_facts": {"rbd_mappings": {}},
    }

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    args = ["rbd", "device", "list", "--format", "json"]
    rc, out, err = module.run_command(args=args)
    if rc != 0:
        module.fail_json(
            msg="Unable to gather rbd mappings.",
            args=args,
            out=out,
            err=err,
            rc=rc,
        )

    if out:
        current_mappings = json.loads(out)
    else:
        current_mappings = {}

    result["ansible_facts"]["rbd_mappings"] = {
        mapping["name"]: mapping for mapping in current_mappings
    }
    module.exit_json(**result)


def main():
    run_module()


if __name__ == "__main__":
    main()
