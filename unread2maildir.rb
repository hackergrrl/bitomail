#!/usr/bin/ruby

# authors:
# * Marcel Kolaja <BM-NBbUtpBXJXVHwWHEWeDovMecqQjEe1oN> (2014)

require 'json/ext'
require 'xmlrpc/client'
require 'maildir'

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

maildir = Maildir.new("/home/stephen/Mail/Bitmessage")

JSON.parse(server.call('getAllInboxMessageIDs'))['inboxMessageIds'].each do |inbox_message_id|
	message = JSON.parse(server.call('getInboxMessageByID', inbox_message_id['msgid']))['inboxMessage'][0]

	# process unread messages only
	if message['read'] == 0
    puts "got one.."
		from_mailaddr = bitaddr_to_mail(message['fromAddress'])
		time_received = Time.at(message['receivedTime'].to_i)

    str = ''
		str += 'From ' + from_mailaddr + ' ' + time_received.asctime
    str += "\n"
		str += 'Date: ' + time_received.strftime('%a, %d %b %Y %H:%M:%S %z')
    str += "\n"
		str += 'From: ' + to_angle(from_mailaddr)
    str += "\n"
		str += 'To: ' + to_angle(bitaddr_to_mail(message['toAddress']))
    str += "\n"
		str += 'Subject: =?utf-8?B?' + message['subject'].gsub(/\n/, '') + '?='
    str += "\n"
		str += 'MIME-Version: 1.0'
    str += "\n"
		str += 'Content-Type: text/plain; charset=utf-8'
    str += "\n"
		str += 'Content-Transfer-Encoding: base64'
    str += "\n"
		str += 'Message-ID: ' +  to_angle(message['msgid'] + $atbitdomain)
    str += "\n"
		str += message['message']
    str += "\n"

    maildir.add(str)

		# mark the message as read
		server.call('getInboxMessageByID', inbox_message_id['msgid'], true)
	end
end
