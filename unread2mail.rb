#!/usr/bin/ruby

# authors:
# * Marcel Kolaja <BM-NBbUtpBXJXVHwWHEWeDovMecqQjEe1oN> (2014)
# * Stephen Whitmore <BM-2cT16UznUfB8C4T3FTvL6yHzAGVfjo4YoJ> (2014)

require 'yaml'
require 'base64'
require 'maildir'
require 'json/ext'
require 'xmlrpc/client'


def bitaddr_to_mail(bitaddr)
  return bitaddr + $atbitdomain
end

def to_angle(id)
  return '<' + id + '>'
end

def get_addressbook(server)
  res = {}
  JSON.parse(server.call('listAddressBookEntries'))['addresses'].each do |address|
    bm_address = address['address']
    bm_label = Base64.decode64(address['label'])
    res[bm_address] = bm_label
  end
  return res
end

# Load configuration
config = {}
begin
  config = YAML.load_file('config.yml')
rescue Errno::ENOENT
end

$atbitdomain = '@bitmessage'
rpc_server = !config.empty? ? config['rpc']['server'] : 'localhost'
rpc_port = !config.empty? ? config['rpc']['port'] : 8442
rpc_user = !config.empty? ? config['rpc']['user'] : ''
rpc_password = !config.empty? ? config['rpc']['password'] : ''

# Object to represent the XML-RPC server
server = XMLRPC::Client.new(rpc_server, nil, rpc_port, nil, nil, rpc_user, rpc_password)

# Retrieve addressbook
addressbook = get_addressbook(server)

# Set mail storage type
maildir = nil
mbox = nil
if config['mail']['maildir'] != nil
  maildir = Maildir.new(config['mail']['maildir'])
elsif config['mail']['mbox'] != nil
  mbox = config['mail']['mbox']
end

# Read (all) messages and publish new ones
new_msgs = 0
JSON.parse(server.call('getAllInboxMessageIDs'))['inboxMessageIds'].each do |inbox_message_id|
  message = JSON.parse(server.call('getInboxMessageByID', inbox_message_id['msgid']))['inboxMessage'][0]

  # Only process unread messages
  if message['read'] == 0
    from_bmaddr = message['fromAddress']
		from_mailaddr = bitaddr_to_mail(from_bmaddr)
    from_name = addressbook[from_bmaddr]
    time_received = Time.at(message['receivedTime'].to_i)

    new_msgs += 1

    # TODO(sww): print to stderr
    STDERR.puts "New message from #{from_bmaddr} " + (from_name != nil ? "(#{from_name})" : "")

		str = 'From ' + from_mailaddr + ' ' + time_received.asctime + "\n"
		str += 'Date: ' + time_received.strftime('%a, %d %b %Y %H:%M:%S %z') + "\n"
		str += 'From: ' + (from_name != nil ? from_name + " " : "") + to_angle(from_mailaddr) + "\n"
		str += 'To: ' + to_angle(bitaddr_to_mail(message['toAddress'])) + "\n"
		str += 'Subject: =?utf-8?B?' + message['subject'].gsub(/\n/, '') + '?=' + "\n"
		str += 'MIME-Version: 1.0' + "\n"
		str += 'Content-Type: text/plain; charset=utf-8' + "\n"
		str += 'Content-Transfer-Encoding: base64' + "\n"
		str += 'Message-ID: ' +  to_angle(message['msgid'] + $atbitdomain) + "\n"
		str += message['message'] + "\n"

    # Write
    if maildir != nil
      # Write to maildir
      maildir.add(str)
    elsif mbox != nil
      # Append to mbox
      open(mbox, 'a') do |f|
        f.puts str
      end
    end

    # Mark message as read
    server.call('getInboxMessageByID', inbox_message_id['msgid'], true)
  end
end

STDERR.puts "#{new_msgs} new messages."
