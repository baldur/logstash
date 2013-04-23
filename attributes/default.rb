default['logstash']['basedir'] = '/opt/logstash'
default['logstash']['user'] = 'logstash'
default['logstash']['group'] = 'logstash'
default['logstash']['join_groups'] = []
default['logstash']['log_dir'] = '/var/log/logstash'
default['logstash']['pid_dir'] = '/var/run/logstash'
default['logstash']['create_account'] = true

# roles/flags for various search/discovery
default['logstash']['graphite_role'] = 'graphite_server'
default['logstash']['graphite_query'] = "roles:#{node['logstash']['graphite_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['elasticsearch_role'] = 'elasticsearch_server'
default['logstash']['elasticsearch_query'] = "roles:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['elasticsearch_cluster'] = 'logstash'
default['logstash']['elasticsearch_ip'] = nil
default['logstash']['elasticsearch_port'] = nil
default['logstash']['graphite_ip'] = ''

default['logstash']['patterns'] = {}
default['logstash']['install_zeromq'] = false

default['logstash']['supports_setuid'] = node.platform == 'ubuntu'
default['logstash']['init_type'] = case node.platform_family
                                   when 'debian'
                                     Gem::Version.new(node.platform_version) >= Gem::Version.new('10.04') ? 'upstart' : 'init.d'
                                   else
                                     'init.d'
                                   end

case
when platform_family?("rhel")
  node.set['logstash']['zeromq_packages'] = [ "zeromq",  "zeromq-devel"]
when platform_family?("debian")
  node.set['logstash']['zeromq_packages'] = [ "zeromq",  "libzmq-dev"]
end
default['logstash']['discovery']['environment_aware'] = true
default['logstash']['discovery']['minimum_response_time_sec'] = false
default['logstash']['discovery']['remove_self'] = false
default['logstash']['discovery']['empty_ok'] = false
