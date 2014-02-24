# Configure the Orabbix Oracle data collector

# The main configuration file template 
# filled with results from node search for all 
# monitored DB servers
db_servers = search(:node, "role:bbmh-learn-zabbix-agent AND role:oracle-database")
Chef::Log.debug "zabbix::orabbix: Found #{db_servers.length}"
# TODO: Make data center specific for larger rollout
template "/etc/zabbix/orabbix.props" do
  source "orabbix/orabbix.props.erb"
  owner "zabbix"
  group "zabbix"
  mode "0644"
  variables({
    :db_servers => db_servers
  })
  # TODO: Add notifies later once template rendering is OK
end

# Dummy file saying where the configuration files are
cookbook_file "/opt/orabbix/conf/README-FILE-LOCATIONS.txt" do
  source "orabbix/README-FILE-LOCATIONS.txt"
  owner "zabbix"
  group "zabbix"
  mode "0644"
end

# Logging configuration
cookbook_file "/etc/zabbix/orabbix-log4j.properties" do
  source "orabbix/orabbix-log4j.properties"
  owner "zabbix"
  group "zabbix"
  mode "0644"
  notifies :restart, "service[orabbix]"
end

# The query list file Orabbix uses to gather info
cookbook_file "/etc/zabbix/orabbix-query.props" do
  source "orabbix/orabbix-query.props"
  owner "zabbix"
  group "zabbix"
  mode 0644
  notifies :restart, "service[orabbix]"
end

case node['platform_family']
when "rhel", "fedora", "suse"
  cookbook_file "/etc/init.d/zabbix-java-gateway" do
    source "zabbix-java-gateway/init.rhel"
    owner "root"
    group "root"
    mode "0755"
  end
end

service "orabbix" do
  service_name "orabbix"
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end
