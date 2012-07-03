## DESCRIPTION

Manages users and groups for the node.

## REQUIREMENTS

Only tested on Debian 6.0.

## USAGE

This cookbook requires that two data bags exists; users and groups.

The group data bag contains a list of group definitions, and the
'users/active\_groups' attribute looks within this data bag for a list of groups
to activate on a node. A group should be defined like this:

````javascript
{
  "gid": 2000,
  "id": "group_name"
}
````

For each group added to a node, the recipe will search for all users that belong
to the group. All matching users are added to the node, as well as any
additional groups that the user might belong to.

For instance; if only the group 'admin' is active on the node, and the user
'test' is in both the group 'admin' and 'manage', both the group 'admin' and the
group 'manage' will exist on the node after the recipe has completed.

A user should be defined like this:

````javascript
{
  "name": "Users Full Name",
  "email": "optional@email.com",
  "groups": [
    "group_name",
    "second_group_name"
  ],
  "id": "test_user",
  "uid": "2000",
  "ssh_keys": [
    "optional array of authorized public keys"
  ],
  "ssh_keypairs": [
    "id_rsa": {
      "private": "optional collection of private and public key pairs",
      "public": "optional collection of private and public key pairs"
    }
  ],
  "ssh_config": {
    "optional_host": {
      "hostname": "optional.actual.host",
      "user": "optional_username",
      "identity_file": "/path/to/optional/identity",
      "strict_host_key_checking": "optional yes/no value"
    }
  }
  "password": "encrypted password (see below)",
  "htpasswd": "optional encrypted htaccess password, used for authenticating the user against htaccess-based services (see below)"
}
````

To generate an encrypted password for use in a user definition, run the following command:

````
mkpasswd -m sha-512
````

To generate an encrypted htaccess password for use in a user definition, run the following command:

````
htpasswd -n <username>
````
