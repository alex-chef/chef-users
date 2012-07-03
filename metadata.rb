maintainer       'Trond Arve Nordheim'
maintainer_email 't@binarymarbles.com'
license          'Apache 2.0'
description      'Manages users and groups for the node'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

supports         'debian'

depends          'ruby-shadow'

recipe           'users', 'Manages users and groups for the node'

attribute 'users',
  :display_name => 'Users',
  :description => 'Hash of user attributes.',
  :type => 'hash'

attribute 'users/active_groups',
  :display_name => 'Active user groups',
  :description => 'An array of user group names that should be active on the node, collected from the "groups" data bag.',
  :type => 'array'
