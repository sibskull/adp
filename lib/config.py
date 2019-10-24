#!/usr/bin/python3

# This is a part of ALT Domain Policies
# Copyright (C) 2019 Andrey Cherepanov <cas@altlinux.org>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see http://www.gnu.org/licenses/.

import logging
import subprocess
import re
import socket
import sys

configuration = None

class Config:
    """ADP Configuration"""
    def __init__( self ):
        global configuration
        self.VERSION = '1.0'
        self.TEMPLATE_PATH="/usr/libexec/adp"
        self.LOG_DIR="/var/log/adp/"
        self.CACHED_LIST="/var/lib/adp/cached_list.db"
        self.CACHED_DIR="/var/lib/adp/Policies"
        self.log_level = logging.ERROR
        self.domain = ''
        self.dc = ''
        self.bind = ''
        configuration = self
        self.object_name = ''
        self.object_type = ''
        self.cache = None

    def set_domain( self, name=None ):
        """Set domain name or detect it"""
        if name != None:
            self.domain = name
            logging.debug( "Set domain name to %s" % ( self.domain ) )
            return

        # Get domain name by command net ads lookup
        try:
            output = subprocess.check_output( [ 'net', 'ads', 'lookup' ], stderr=subprocess.STDOUT ).decode()
        except Exception as e:
            logging.error( "Unable to detect domain name: %s" % ( e ) )
            sys.exit( 1 )

        # Parse ^Domain:...
        d = re.search( "^Domain:\s*(\S+)\n", output, re.MULTILINE )
        if d:
            self.domain = d.group( 1 )
            logging.debug( "Autodetected domain name: %s" % ( self.domain ) )

        # Get domain controller FQDN
        d = re.search( "^Domain Controller:\s*(\S+)\n", output, re.MULTILINE )
        if d:
            self.dc = d.group( 1 )
            logging.debug( "Domain controller: %s" % ( self.dc ) )
        
        # Generate bind for LDAP
        self.bind = ",".join( map( lambda x: "DC=" + x, self.domain.split( '.' ) ) )

        # TODO: support domain part in cache and log pathes

    def check_access( self ):
        """Check Kerberos ticket or obtain Kerberos ticket for machine"""

        # Check for any Kerberos ticket
        try:
            # Check Kerberos ticket by `klist -s`
            subprocess.check_call( [ 'klist', '-s' ] )
            logging.debug( subprocess.check_output( 'klist', stderr=subprocess.STDOUT ).decode() )
            return True
        except:
            logging.debug( 'There is no Kerberos ticket, try to get ticket for machine' )

        
        machine_name = socket.gethostname().split('.', 1)[0].upper() + "$"
        subprocess.call( [ 'kinit', '-k', machine_name ] )
        
        try:
            # Check Kerberos ticket by `klist -s`
            subprocess.check_call( [ 'klist', '-s' ] )
            logging.debug( subprocess.check_output( 'klist', stderr=subprocess.STDOUT ).decode() )
            return True
        except:
            logging.debug( 'There is no available Kerberos ticket' )

        return False

