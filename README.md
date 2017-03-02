# Zabbix MySQL backup

This is a MySQL/Postgres database backup script for the [Zabbix](http://www.zabbix.com/) monitoring software from version 1.3.1 up to 3.0.7.

## Download

Download the latest (stable) release here:

https://github.com/maxhq/zabbix-backup/releases/latest

## More informations

Please see the [Project Wiki](https://github.com/maxhq/zabbix-backup/wiki).

## Version history

**0.8.2 (2016-09-08)**

- NEW: Option -x to use XZ instead of GZ for compression (Jonathan Wright)
- NEW: Option -0 for "no compression"
- FIX: Evil space was masking end of here-document (fixed in #8 by @msjmeyer)
- FIX: Prevent "Warning: Using a password on the command line interface can be insecure."

**0.8.1 (2016-07-11)**

- ENH: Added Zabbix 3.0.x tables to list (added & tested by Ruslan Ohitin)

**0.8.0 (2016-01-22)**

- FIX: Only invoke `dig` if available
- ENH: Option -c to use a MySQL config ("options") file (suggested by Daniel Schneller)
- ENH: Option -r to rotate backup files (Daniel Schneller)
- ENH: Add database version to filename if available
- ENH: Add quiet mode. IP reverse lookup optional (Daniel Schneller)
- ENH: Bash related fixes (Misu Moldovan)
- CHG: Default output directory is now $PWD instead of script dir

**0.7.1 (2015-01-27)**

- NEW: Parsing of commandline arguments implemented
- ENH: Try reverse lookup of IPs and include hostname/IP in filename
- REV: Stop if database password is wrong

**0.7.0 (2014-10-02)**

- ENH: Complete overhaul to make script work with lots of Zabbix versions

**0.6.0 (2014-09-15)**

- REV: Updated the table list for use with zabbix v2.2.3

**0.5.0 (2013-05-13)**

- NEW: Added table list comparison between database and script

**0.4.0 (2012-03-02)**

- REV: Incorporated mysqldump options (suggested by Jonathan Bayer)

**0.3.0 (2012-02-06)**

- ENH: Backup of Zabbix 1.9.x / 2.0.0, removed unnecessary use of
  variables (DATEBIN etc) for commands that use to be in $PATH

**0.2.0 (2011-11-05)**
