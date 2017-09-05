#
# Cookbook:: sti_crc_method_comparison
# Recipe:: accounts
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Generate accounts from vault

accounts = chef_vault_item('sti_crc_method_comparison', 'accounts')
configs = chef_vault_item('sti_crc_method_comparison', 'configs')

accounts.each_pair do |username, pass|
  user username do
    comment "sti upload account for #{username}"
    gid 'nogroup'
    home "#{configs['data_dir']}/#{username}"
    manage_home false
    password pass
    system true
  end
  directory "#{configs['data_dir']}/#{username}" do
    owner 'root'
    group 'root'
    mode '0755'
  end
  directory "#{configs['data_dir']}/#{username}/upload" do
    owner username
    group 'root'
    mode '0755'
  end
end
