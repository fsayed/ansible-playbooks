# users role

Manage users

## Variables

local_users - a list of users to be created or removed (see an example below)

## Example

    ---
    local_users:
        - username: bkanagar
          uid: 1380
          comment: Brian Kanagar
          state: present

        - username: parinya
          password: '$6$.uVxEVg3$wV1V4fh34D2S577SMjUTQtmX4eskapMbKixFKtNS.XYYavygj1p8wEyoqvks9UmeJRwcAmeZGzVa.AIt2TO215'
          uid: 1392
          group: users
          groups: syseng
          comment: Parinya Thipchart
          home: /home/parinya
          shell: /bin/bash
          state: present

        - username: fsayed
          password: '!!'
          uid: 1412
          group: users
          groups:
          comment: Fahad Sayed
          home: /home/fsayed
          shell: /bin/bash
          state: present
                      
