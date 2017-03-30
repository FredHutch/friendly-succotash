#
# Cookbook Name:: sti_crc_method_comparison
# Recipe:: sftp_server
#
# Copyright (c) 2017 The Authors, All Rights Reserved.
#
# Configures an sftp server by creating an alternate OpenSSH server running on
# an IP address dedicated to sftp services.  This OpenSSH server will not
# provide shell access.  This cookbook will create and manage an interface on
# the host- currently it will create a subinterface on the node's default
# interface (`node['network']['default_interface']`) if a device is not
# specified via `configs['device']
#
# This will affect the configuration of openssh on the node.  This recipe will
# take all configured IP addresses on the node, remove the one indicated for
# the sftp server (the attribute `configs['inet_addr']`), and put
# the remaining IP addresses in `sshd_config` as the `ListenAddress` for the
# primary, shell access, openssh server.

# Check- if the sftp_server device is the primary interface (node's default
# interface in ohai), raise an error so we don't clobber that.

configs = chef_vault_item('sti_crc_method_comparison', 'configs')

# Default device sub-interface on host default interface if unset
configs['device'] ||= "#{node['network']['default_interface']}:1"

# Check to make sure we are not configured to run on the same network
# device as the host default interface
default_interface = node['network']['default_interface']
raise 'sftp_server device cannot run on default interface. Exiting.' if \
  configs['device'] == default_interface

# Configure sftp interface
ifconfig configs['inet_addr'] do
  device configs['device']
  inet_addr configs['inet_addr']
  mask configs['netmask']
  onboot 'yes'
  onparent 'yes'
  action :add
end

include_recipe 'openssh'

# Create configuration for an "alt-sftp" server
#
# this command will be used to install this as a service
execute 'systemd-reload' do
  command '/bin/systemctl daemon-reload'
  action :nothing
  notifies :run, 'execute[sftp-enable]', :immediately
end

# openssh config file enabling sftp only
template configs['config'] do
  owner 'root'
  group 'root'
  mode '0600'
  source 'sshd_sftp_only_config.erb'
  variables(
    'sftp_server_address' => configs['inet_addr'],
    'sftp_server_data_dir' => configs['data_dir']
  )
end

# `defaults` file for this service
template '/etc/default/sftp_server' do
  owner 'root'
  group 'root'
  mode '0600'
  source 'sftp_config.erb'
  variables(
    'config_file' => configs['config']
  )
  notifies :restart, 'service[sftpd.service]', :delayed
end

# systemd service file- reloads systemd on execution
template '/lib/systemd/system/sftp_server.service' do
  owner 'root'
  group 'root'
  mode '0644'
  source 'sftp_server.service.erb'
  notifies :run, 'execute[systemd-reload]', :immediately
end

# create data directory
directory configs['data_dir'] do
  owner 'root'
  group 'root'
  mode 0x0755
  recursive true
end

execute 'sftp-enable' do
  command '/bin/systemctl enable sftp_server.service'
end

service 'sftpd.service' do
  action :start
end
