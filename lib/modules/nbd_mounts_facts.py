#!/usr/bin/env python3
from ansible.module_utils.basic import AnsibleModule


DOCUMENTATION = r'''
---
module: nbd_devices_facts

short_description: Gathers facts about nbd devices

version_added: "1.0.0"

description: Checks the current mapped nbd modules and the devices they are
mapped too and adds facts describing those.

author:
    - David Caro <david@dcaro.es>
'''

EXAMPLES = r'''
- name: Return ansible_facts
  my_namespace.my_collection.my_test_facts:
'''

RETURN = r'''
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
'''


def run_module():
    module_args = {
        "name": {"type": "str", "required": True},
    }

    result = {
        "changed": False,
        "original_message": "",
        "message": "",
        "my_useful_info": {},
    }

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    result["original_message"] = module.params["name"]
    result["message"] = "goodbye"
    result["my_useful_info"] = {
        "foo": "bar",
        "answer": 42,
    }
    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)
