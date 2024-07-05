# groups role

Manage groups

## Variables

local_groups - a list of groups

## Example

    ---
    local_groups:
        - id: 1015
          name: syseng
          state: present

        - id: 1016
          name: neteng
          state: present

        - id: 1109
          name: noc
          state: present



