node.default['sftp_server'] = {
  'device' => "#{node['network']['default_interface']}:1",
  'inet_addr' => '172.16.3.3',
  'network' => '172.16.3.1',
  'netmask' => '255.255.255.0',
  'data_dir' => '/var/opt/sftp'
}
