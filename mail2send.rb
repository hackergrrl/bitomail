#!/usr/bin/ruby

# authors:
# * Marcel Kolaja <BM-NBbUtpBXJXVHwWHEWeDovMecqQjEe1oN> (2014)
# * Filip Krška <BM-2cSvE6gCTCVUyFNzo7D1Z43gNPAZ8cx1m4> (2014)

require 'base64'
require 'mail'
require 'json/ext'
require 'xmlrpc/client'

# variables that need to be set
fromAddress = ''
rpc_server = 'localhost'
rpc_port = 8442
rpc_user = ''
rpc_password = ''

mail = Mail.new(STDIN.read(nil))

# Make an object to represent the XML-RPC server.
server = XMLRPC::Client.new(rpc_server, nil, rpc_port, nil, nil, rpc_user, rpc_password)

ack_data = server.call('sendMessage', /\A(.*)@/.match(mail.to[0])[1], fromAddress, Base64.encode64(mail.subject), Base64.encode64(mail.body.to_s))
abort ack_data if /\AAPI Error/.match(ack_data)
