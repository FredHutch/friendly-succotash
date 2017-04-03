#
# Cookbook Name:: sti_crc_method_comparison
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

package [
    'samba-common',
    'samba-common-bin',
    'samba-libs',
    'cifs-utils'
]

include_recipe 'chef-vault::default'

configs = chef_vault_item('sti_crc_method_comparison', 'configs')

# create data directory
directory configs['data_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

# create credentials file
template "/etc/samba/.credentials.#{configs['mount']['user']}" do
  owner 'root'
  group 'root'
  mode '0600'
  variables(
    'username' => configs['mount']['user'],
    'password' => configs['mount']['pass'],
    'domain' => configs['mount']['wkgp']
  )
  source 'credentials.erb'
end

mount_options = [
  "credentials=/etc/samba/.credentials.#{configs['mount']['user']}",
  'uid=root',
  'gid=root',
  'file_mode=0644',
  'dir_mode=0755'
]

mount configs['data_dir'] do
  device configs['mount']['path']
  fstype 'cifs'
  options mount_options.join(',')
  action [:enable]
end

include_recipe 'sti_crc_method_comparison::sftp_server'
include_recipe 'sti_crc_method_comparison::accounts'
