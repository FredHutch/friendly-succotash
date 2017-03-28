#
# Cookbook:: sti_crc_method_comparison
# Recipe:: accounts
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Generate accounts from vault

accounts = chef_vault_item('sti_crc_method_comparison', 'accounts')
configs = chef_vault_item('sti_crc_method_comparison', 'configs')

accounts.each_pair do |name, pass|
  user name do
    comment 'sti upload account'
    gid 'nogroup'
    home "#{configs['data_dir']}/#{name}"
    manage_home false
    password pass
    system true
  end
end
