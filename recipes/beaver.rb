#
# Cookbook Name:: logstash
# Recipe:: beaver
#
#

include_recipe 'logstash::beaver_dependencies'

raise 'WTF'

logstash_server_ip = nil
if Chef::Config[:solo]
  logstash_server_ip = node['logstash']['beaver']['server_ipaddress']
elsif node['logstash']['beaver']['server_ipaddress']
  logstash_server_ip = node['logstash']['beaver']['server_ipaddress']
elsif node['logstash']['beaver']['server_role']
  logstash_server_results = search(:node, "roles:#{node['logstash']['beaver']['server_role']}")
  unless logstash_server_results.empty?
    logstash_server_ip = logstash_server_results[0]['ipaddress']
  end
end

# inputs
files = []
node['logstash']['beaver']['inputs'].each do |ins|
  ins.each do |name, hash|
    case name
    when "file" then
      if hash.has_key?('path')
        files << hash
      else
        log("input file has no path.") { level :warn }
      end
    else
      log("input type not supported: #{name}") { level :warn }
    end
  end
end

# outputs
outputs = []
conf = {}
node['logstash']['beaver']['outputs'].each do |outs|
  outs.each do |name, hash|
    case name
    when "rabbitmq", "amqp" then
      outputs << "rabbitmq"
      host = hash['host'] || logstash_server_ip || 'localhost'
      conf['rabbitmq_host'] = hash['host'] if hash.has_key?('host')
      conf['rabbitmq_port'] = hash['port'] if hash.has_key?('port')
      conf['rabbitmq_vhost'] = hash['vhost'] if hash.has_key?('vhost')
      conf['rabbitmq_username'] = hash['user'] if hash.has_key?('user')
      conf['rabbitmq_password'] = hash['password'] if hash.has_key?('password')
      conf['rabbitmq_queue'] = hash['queue'] if hash.has_key?('queue')
      conf['rabbitmq_exchange_type'] = hash['rabbitmq_exchange_type'] if hash.has_key?('rabbitmq_exchange_type')
      conf['rabbitmq_exchange'] = hash['exchange'] if hash.has_key?('exchange')
      conf['rabbitmq_exchange_durable'] = hash['durable'] if hash.has_key?('durable')
      conf['rabbitmq_key'] = hash['key'] if hash.has_key?('key')
    when "redis" then
      outputs << "redis"
      host = hash['host'] || logstash_server_ip || 'localhost'
      port = hash['port'] || '6379'
      db = hash['db'] || '0'
      conf['redis_url'] = "redis://#{host}:#{port}/#{db}"
      conf['redis_namespace'] = hash['key'] if hash.has_key?('key')
    when "stdout" then
      outputs << "stdout"
    when "zmq", "zeromq" then
      outputs << "zmq"
      host = hash['host'] || logstash_server_ip || 'localhost'
      port = hash['port'] || '2120'
      conf['zeromq_address'] = "tcp://#{host}:#{port}"
    else
      raise "Unsupported beaver output type provided: #{name}"
    end
  end
end

output = outputs[0]
if outputs.length > 1
  log("multiple outputs detected, will consider only the first: #{output}") { level :warn }
end

logstash_beaver 'default' do
  output conf
  files files
end
