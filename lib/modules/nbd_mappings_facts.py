#!/usr/bin/env python3
from ansible.module_utils.basic import AnsibleModule
import json


DOCUMENTATION = r"""
---
module: nbd_mappings_facts

short_description: Gathers facts about nbd devices

version_added: "1.0.0"

description: Checks the current mapped nbd modules and the devices they are
mapped too and adds facts describing those.

author:
    - David Caro <david@dcaro.es>
"""

EXAMPLES = r"""
- name: Return ansible_facts
  my_namespace.my_collection.my_test_facts:
"""

RETURN = r"""
ansible_facts:
  description: Facts to add to ansible_facts.
  returned: always
  type: dict
  contains:
    foo:
      description: Foo facts about operating system.
      type: str
      returned: when operating system foo fact is present
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
        "ansible_facts": {"nbd_mappings": {}},
    }

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    args = ["rbd-nbd", "list-mapped", "--format", "json"]
    rc, out, err = module.run_command(args=args)
    if rc != 0:
        module.fail_json(
            msg="Unable to gather nbd mappings.",
            args=args,
            out=out,
            err=err,
            rc=rc,
        )

    if out:
        current_mappings = json.loads(out)
    else:
        current_mappings = {}

    result["ansible_facts"]["nbd_mappings"] = {
        mapping["image"]: mapping for mapping in current_mappings
    }
    module.exit_json(**result)


def main():
    run_module()


if __name__ == "__main__":
    main()
