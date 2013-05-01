# Brightbox Bootstaller

This is a [iPXE](http://ipxe.org/) menu script that allows you to netboot and autobuild servces on [Brightbox](http://brightbox.com/) Cloud.

## To Build

In a suitable directory

* Replicate this repository - `git clone git@github.com:brightbox/bootstaller.git`
* Replicate the ipxe repository alongside - `git clone git://git.ipxe.org/ipxe.git`
* Change into the bootstaller directory - `cd bootstaller'
* Run `rake`

This creates two bootable images `bootstaller-x86_64.usb` and `bootstaller-i686.usb`

## To Upload the images

To upload the images to your image library on Brightbox Cloud run:

`CLIENT=<your client alias> rake upload`

## License

Copyright (C) 2013 Brightbox Systems 

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
