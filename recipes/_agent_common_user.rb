# RHEL 5 and below does not seem to support
# managed home directories.
manage_home = true # most distros do support managed home so leave at true
if (node['platform_family'] == 'rhel')
  rhel_major = (/[0-9]+\.[0-9]+/.match(node['platform_version']))[0].to_i
  rhel_major <= 5 && manage_home = false
end

# Manage user and group
if node['zabbix']['agent']['user']
  # Create zabbix group
  group node['zabbix']['agent']['group'] do
    gid node['zabbix']['agent']['gid'] if node['zabbix']['agent']['gid']
    system true
  end

  # Create zabbix User
  user node['zabbix']['agent']['user'] do
    home node['zabbix']['install_dir']
    shell node['zabbix']['agent']['shell']
    uid node['zabbix']['agent']['uid'] if node['zabbix']['agent']['uid']
    gid node['zabbix']['agent']['gid'] || node['zabbix']['agent']['group']
    system true
    supports :manage_home => manage_home
  end
end
