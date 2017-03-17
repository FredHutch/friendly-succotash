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
# specified via `node['sftp_server']['device']
#
# This will affect the configuration of openssh on the node.  This recipe will
# take all configured IP addresses on the node, remove the one indicated for
# the sftp server (the attribute `node['sftp_server']['inet_addr']`), and put
# the remaining IP addresses in `sshd_config` as the `ListenAddress` for the
# primary, shell access, openssh server.

# Check- if the sftp_server device is the primary interface (node's default
# interface in ohai), raise an error so we don't clobber that.

default_interface = node['network']['default_interface']

raise 'sftp_server device cannot run on default interface. Exiting.' if \
  node['sftp_server']['device'] == default_interface

# Configure sftp interface
ifconfig node['sftp_server']['inet_addr'] do
  device node['sftp_server']['device']
  inet_addr node['sftp_server']['inet_addr']
  mask node['sftp_server']['netmask']
  onboot 'yes'
  onparent 'yes'
  action :add
end

# reconfigure host openssh to listen only on default address

# Find ip address assigned to default interface by searching addresses
# configured to the device for an `inet` address

default_interface_addrs = \
  node['network']['interfaces'][default_interface]['addresses']
default_interface_ip = \
  default_interface_addrs.select { |_k, v| v['family'] == 'inet' }.keys[0]

# set openssh listenaddress to this IP address
node.override['openssh']['server']['listen_address'] = default_interface_ip

include_recipe 'openssh'

# Create configuration for an "alt-sftp" server
#
# this command will be used to install this as a service
execute 'systemd-reload' do
  command '/bin/systemctl daemon-reload'
  action :nothing
end

# openssh config file enabling sftp only
template node['sftp_server']['config'] do
  owner 'root'
  group 'root'
  mode '0600'
  source 'sshd_sftp_only_config.erb'
  variables(
    'sftp_server_address' => node['sftp_server']['inet_addr'],
    'sftp_server_data_dir' => node['sftp_server']['data_dir']
  )
end

# `defaults` file for this service
template '/etc/default/sftp_server' do
  owner 'root'
  group 'root'
  mode '0600'
  source 'sftp_config.erb'
  variables(
    'config_file' => node['sftp_server']['config']
  )
end

# systemd service file- reloads systemd on execution
template '/lib/systemd/system/sftp_server.service' do
  owner 'root'
  group 'root'
  mode '0644'
  source 'sftp_server.service.erb'
  notifies :run, 'execute[systemd-reload]', :immediately
end

