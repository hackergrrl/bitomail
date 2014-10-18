Notice
======
This is currently an unmerged fork of Marcel Kolaja's
[Bitomail](http://personal.kolaja.eu/projects.html) project. I've moved a copy
here to both a) give it a presence on GitHub, and b) develop my own additions.


Bitomail
========
Bitomail allows you to operate Bitmessage with your e-mail client (MUA). You
need a running Bitmessage node providing the PyBitmessage XML-RPC API:

https://bitmessage.org/wiki/API_Reference

Currently, Bitomail contains two scripts:

* unread2mbox.rb
* mail2send.rb

unread2mbox.rb prints all unread Bitmessages in a UNIX mbox format and marks
them as read in Bitmessage.

mail2send.rb sends mail provided on STDIN through Bitmessage.


How to run Bitomail
-------------------
Place unread2mbox.rb and mail2send.rb somewhere on your filesystem, where you
will run them from. It is assumed in this document that you placed these
scripts into ~/bin/.

Bitomail is in very early development and has no configuration files at the
moment. You need to edit _both_ scripts in order to serve your needs. You have
to set the variables outlined in the scripts.

It is assumed further in this document that your inbox is in ~/Mail/INBOX.

Start the Bitmessage node and configure it properly, so that Bitomail can
access the XML-RPC API.

Run the following command periodically, so that newly received Bitmessages are
placed in your inbox:

$ ~/bin/unread2mbox.rb >> ~/Mail/INBOX

Now you can read your Bitmessages in your MUA.

In order to send Bitmessages from your MUA, set ~/bin/mail2send.rb as
a sendmail program in your MUA configuration. Now, you can send Bitmessages
from your MUA, as long as you put the Bitmessage address in the local part of
the e-mail address in the To: header. Please, note that the address has to
contain `@', which marks the end of the Bitmessage address.  Anything after `@'
is omitted.


Disclaimer
----------
Bitomail is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

Bitomail is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
Bitomail. If not, see <http://www.gnu.org/licenses/>.

♡ Marcel Kolaja
