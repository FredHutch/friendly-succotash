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

default_interface_addrs = \
  node['network']['interfaces'][default_interface]['addresses']
default_interface_ip = \
  default_interface_addrs.select { |_k, v| v['family'] == 'inet' }.keys[0]
node.override['openssh']['server']['listen_address'] = default_interface_ip

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
include_recipe 'openssh'
