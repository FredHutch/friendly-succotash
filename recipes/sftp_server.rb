#
# Cookbook Name:: friendly-succotash
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
#
# This recipe will throw an error if the IP address indicated for the sftp
# server would leave only the loopback address for the shell openssh server
#

# Check- if the sftp_server device is the primary interface (node's default
# interface in ohai), raise an error so we don't clobber that.

raise 'sftp_server device cannot run on default interface. Exiting.' if (
  node['sftp_server']['device'] == node['network']['default_interface']
)

# Configure sftp interface
ifconfig node['sftp_server']['inet_addr'] do
  device node['sftp_server']['device']
  inet_addr node['sftp_server']['inet_addr']
  mask node['sftp_server']['netmask']
  onboot 'yes'
  onparent 'yes'
  action :add
end

