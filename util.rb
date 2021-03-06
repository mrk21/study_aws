require 'erb'
require 'aws-sdk'
require 'json'
require 'net/ssh'
require 'pp'

def aws(cmd, bind = binding)
  puts cmd = ERB.new(cmd.gsub(/\s+/, ' ').strip).result(bind)
  puts json = %x(#{cmd})
  json = JSON.parse json rescue ''
end

def ssh(options = {})
  return unless options[:host]
  options[:user] ||= 'ec2-user'
  options[:key] ||= '~/.ssh/default.pem'
  
  if options[:cmd] then
    puts options[:cmd]
    Net::SSH.start(options[:host], options[:user], keys: [options[:key]]) do |ssh|
      channel = ssh.open_channel do |ch|
        channel.request_pty do |ch, success|
          raise "Could not obtain pty " if !success
        end
        
        channel.exec options[:cmd] do |ch, success|
          ch.on_data do |c, data|
            print data
          end
        end
      end
      
      ssh.loop
    end
  else
    ssh = "ssh -i #{options[:key]} #{options[:user]}@#{options[:host]}"
    puts ssh
    exec ssh
  end
end

def create_instance(options = {})
  options[:n] ||= 1
  options[:tag] ||= 'tmp'
  
  ids = options[:n].times.map do
    ec2 = aws <<-SH, binding
      aws ec2 run-instances
        --image-id         ami-383c1956 <%# Amazon Linux %>
        --instance-type    t2.micro
        --security-groups  default
        --key-name         default
    SH
    aws <<-SH, binding
      aws ec2 create-tags
        --resources  <%= ec2['Instances'][0]['InstanceId'] %>
        --tags       'Key=Name,Value=<%= options[:tag] %>'
    SH
    
    ec2['Instances'][0]['InstanceId']
  end
  
  ec2s = loop do
    ec2s = aws(<<-SH, binding)
      aws ec2 describe-instances
        --instance-ids  <%= ids.join(' ') %>
        --query         'Reservations[*]'
    SH
    
    break ec2s if ec2s.all? do |ec2|
      not ec2['Instances'][0]['PublicDnsName'].empty?
    end
    
    sleep 5
  end
  
  ec2s.each do |ec2|
    begin
      puts "Ping #{ec2['Instances'][0]['PublicDnsName']}"
      ssh host: ec2['Instances'][0]['PublicDnsName'], cmd: 'echo OK'
    rescue Errno::ECONNREFUSED => e
      pp e
      sleep 10
      retry
    end
  end
  
  ec2s
end

def destroy_instance(options = {})
  options[:tag] ||= 'tmp'
  
  ec2_ids = get_instance \
    tag: options[:tag],
    query: 'Reservations[*].Instances[*].InstanceId'
  
  aws <<-SH, binding
    aws ec2 terminate-instances
      --instance-ids  <%= ec2_ids.flatten.join(' ') %>
  SH
end

def get_instance(options = {})
  aws <<-SH, binding
    aws ec2 describe-instances
      --filters  'Name=tag-key,Values=Name'
                 'Name=tag-value,Values=<%= options[:tag] %>'
                 <% if options[:state] then %>
                   'Name=instance-state-name,Values=<%= options[:state] %>'
                 <% end %>
      <% if options[:query] && !options[:query].empty? then %>
        --query  <%= options[:query] %>
      <% end %>
  SH
end

def attach_tag(resource_id, tag_name)
  aws <<-SH, binding
    aws ec2 create-tags
      --resources  <%= resource_id %>
      --tags       'Key=Name,Value=<%= tag_name %>'
  SH
end

def create_or_get_instance(options = {})
  options[:on_create] ||= ->{}
  ec2s = get_instance options.merge(state: 'running', query: 'Reservations[*]')
  if ec2s.empty? then
    ec2s = create_instance tag: options[:tag]
    options[:on_create][ec2s]
  end
  ec2s
end

def dynamodb_client
  db = Aws::DynamoDB::Client.new \
    region: 'ap-northeast-1'
end

def create_json(filename, object)
  File.write filename, JSON.generate(object)
  filename
end
