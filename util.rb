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
