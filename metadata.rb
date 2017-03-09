name 'friendly-succotash'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'all_rights'
description 'Installs/Configures friendly-succotash'
long_description 'Installs/Configures friendly-succotash'
version '0.1.0'
issues_url 'fill this in'
source_url 'and this too'

depends 'openssh', '~> 2.1'

attribute 'sftp-server/address',
          'display_name' => 'IP/hostname for sftp server',
          'type'         => 'string',
          'required'     => 'required',
          'recipes'      => ['friendly-succotash::sftp_server']
