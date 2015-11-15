require 'erb'
require 'aws-sdk'
require 'pp'

def aws(cmd, bind = binding)
  puts cmd = ERB.new(cmd.gsub(/\s+/, ' ').strip).result(bind)
  puts json = %x(#{cmd})
  json = JSON.parse json rescue ''
end
