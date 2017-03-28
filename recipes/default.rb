#
# Cookbook Name:: sti_crc_method_comparison
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

include_recipe 'chef-vault::default'
include_recipe 'sti_crc_method_comparison::accounts'
include_recipe 'sti_crc_method_comparison::sftp_server'
