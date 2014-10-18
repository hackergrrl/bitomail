#!/usr/bin/ruby

# authors:
# * Marcel Kolaja <BM-NBbUtpBXJXVHwWHEWeDovMecqQjEe1oN> (2014)
# * Filip Krška <BM-2cSvE6gCTCVUyFNzo7D1Z43gNPAZ8cx1m4> (2014)

require 'base64'
require 'mail'
require 'json/ext'
require 'xmlrpc/client'

# Load configuration
config = {}
begin
  config = YAML.load_file('config.yml')
rescue Errno::ENOENT
  puts "file not found"
end

from_address = config['rpc']['address']
rpc_server = config['rpc']['server']
rpc_port = config['rpc']['port']
rpc_user = config['rpc']['user']
rpc_password = config['rpc']['password']


mail = Mail.new(STDIN.read(nil))

# Make an object to represent the XML-RPC server.
server = XMLRPC::Client.new(rpc_server, nil, rpc_port, nil, nil, rpc_user, rpc_password)

to = /\A(.*)@/.match(mail.to[0])[1]
subject = Base64.encode64(mail.subject)
body = Base64.encode64(mail.body.to_s)
ack_data = server.call('sendMessage', to, from_address, subject, body)

abort ack_data if /\AAPI Error/.match(ack_data)

