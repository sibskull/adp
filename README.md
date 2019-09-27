# Script for apply ALT Domain Policies

This script apply ALT Domain Policy (Linux-specific rules for Active
Directory GPO) for user or machine. It requires user or machine Kerberos
ticket before use.

## Usage

- Adp.service should be run under root privileges to apply policies for machine.
- For fetch policy from server for user add /usr/sbin/adp-fetch for pam_exec.so:
  Append to /etc/pam.d/system-auth:

 session         optional        pam_exec.so      /usr/sbin/adp-fetch

- Log verbosity is controlled in file /etc/sysconfig/adp:
VERBOSE="yes"
DEBUG="yes"

Log files is separated by user name and action (apply or fetch) and placed 
to /var/log/adp.

- Autostart desktop file run `adp apply` for user using cached data.

## License

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

