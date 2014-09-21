#!/usr/bin/ruby

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

def send_message(mail_in_text)
	parsed_mail = Mail.new(mail_in_text)
	ack_data = $server.call('sendMessage', /\A(.*)@/.match(parsed_mail.to[0])[1], fromAddress, Base64.encode64(parsed_mail.subject), Base64.encode64(parsed_mail.body.to_s))

	puts ack_data
end

# Make an object to represent the XML-RPC server.
$server = XMLRPC::Client.new(rpc_server, nil, rpc_port, nil, nil, rpc_user, rpc_password)

mail_to_send = nil
while (line = STDIN.gets)
	if (line.match(/\AFrom /))
		if (mail_to_send)
			send_message(mail_to_send)
		end
		mail_to_send = ''
	else
		mail_to_send << line.sub(/^\>From/, 'From')
	end
end

# we are at the end of the mailbox; send the last message
send_message(mail_to_send)
