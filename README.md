Notice
======
This is currently an unmerged fork of Marcel Kolaja's
[Bitomail](http://personal.kolaja.eu/projects.html) project. I've moved a copy
here to both a) give it a presence on GitHub, and b) develop my own additions
(to hopefully merge back in).


Bitomail
========
Bitomail allows you to operate
[BitMessage](https://bitmessage.org/wiki/Main_Page) with your e-mail client
(MUA). You need a running BitMessage node providing the [PyBitmessage XML-RPC
API](https://bitmessage.org/wiki/API_Reference).

Currently, Bitomail contains two scripts:

* `unread2mail.rb`
* `mail2send.rb`

`unread2mail.rb` reads all unread messages from the PyBitmessage server and
writes them to either a maildir or mbox file. Those messages are then flagged as
read on the server.

`mail2send.rb` sends mail provided on STDIN through BitMessage.


How to use Bitomail
-------------------
Place the scripts somewhere on your filesystem, where you will run them.
It is assumed in this document that you placed these scripts into ~/bin/.

Configuration is done through a `config.yml` YAML file you should create in the
same directory as the scripts. The following is an example configuration,
illustrating all supported fields:

```
rpc:
  server: 'localhost'
  port: 8442
  user: 'user'
  password: 'password'

from:
  address: 'BM-someaddressgeneratedforyoubybitmessage'
  name: 'Foo Bar'

mail:
  maildir: "/home/foobar/Mail/BitMessage"   # comment to not use
  #mbox: "/home/foobar/bitmsg.mbox"         # uncomment to use
```

Run `unread2mail.rb` periodically, so that newly received BitMessages are placed
in your maildir or mbox. You can then read your BitMessages in your mail client
of choice.

In order to send BitMessages from your mail client, set `mail2send.rb` as your
sendmail program in your mail client configuration. You can then send
BitMessages from your mail client as long as you put the BitMessage address in the
local part of the e-mail address in the To: header. (e.g.
BM-whatever@bitmessage). The address must contain `@', which marks the end of
the BitMessage address. Anything after `@' is omitted.



 (c) 2014 Marcel Kolaja, Stephen Whitmore

