default_interface = node['network']['default_interface']
default_interface_addrs = \
  node['network']['interfaces'][default_interface]['addresses']
default_interface_ip = \
  default_interface_addrs.select { |_k, v| v['family'] == 'inet' }.keys[0]
node.override['openssh']['server']['listen_address'] = default_interface_ip
