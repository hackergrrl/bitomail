#!/usr/bin/ruby

require 'json/ext'
require 'xmlrpc/client'

# variables that need to be set
$atbitdomain = '@bitmessage'
rpc_server = 'localhost'
rpc_port = 8442
rpc_user = ''
rpc_password = ''

def bitaddr_to_mail(bitaddr)
	return bitaddr + $atbitdomain
end

def to_angle(id)
	return '<' + id + '>'
end

# Make an object to represent the XML-RPC server.
server = XMLRPC::Client.new(rpc_server, nil, rpc_port, nil, nil, rpc_user, rpc_password)

JSON.parse(server.call('getAllInboxMessageIDs'))['inboxMessageIds'].each do |inbox_message_id|
	message = JSON.parse(server.call('getInboxMessageByID', inbox_message_id['msgid']))['inboxMessage'][0]

	# process unread messages only
	if message['read'] == 0
		from_mailaddr = bitaddr_to_mail(message['fromAddress'])
		time_received = Time.at(message['receivedTime'].to_i)

		puts 'From ' + from_mailaddr + ' ' + time_received.asctime
		puts 'Date: ' + time_received.strftime('%a, %d %b %Y %H:%M:%S %z')
		puts 'From: ' + to_angle(from_mailaddr)
		puts 'To: ' + to_angle(bitaddr_to_mail(message['toAddress']))
		puts 'Subject: =?utf-8?B?' + message['subject'].gsub(/\n/, '') + '?='
		puts 'MIME-Version: 1.0'
		puts 'Content-Type: text/plain; charset=utf-8'
		puts 'Content-Transfer-Encoding: base64'
		puts 'Message-ID: ' +  to_angle(message['msgid'] + $atbitdomain)
		puts
		puts message['message']
		puts
	
		# mark the message as read
		server.call('getInboxMessageByID', inbox_message_id['msgid'], true)
	end
end
