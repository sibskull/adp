# Script for apply ALT Domain Policies

This script apply ALT Domain Policy (Linux-specific rules for Active
Directory GPO) for user or machine. It requires user or machine Kerberos
ticket before use.

Usage: adp [-h] [-v] [-d] [--version] {user,machine} [object]

positional arguments:
  {user,machine}  Class of policies: user or machine
  object          Name of user or machine (optional)

optional arguments:
  -h, --help      show this help message and exit
  -v              Verbose output
  -d              Debug output
  --version       show program's version number and exit

## License

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

