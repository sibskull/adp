#!/usr/bin/python3

# Script for apply ALT Domain Policies
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

import argparse
import getpass
import socket
import subprocess
import sys
import re

VERSION = '0.1'

class DomainPolicies:
    """Class for get GPO for specified policy class and apply they"""
    def __init__( self, t, verbose, debug, obj=None ):
        self.list = []
        self.c = t
        self.is_verbose = verbose
        self.is_debug = debug
        if obj:
            self.object = obj
        elif self.c == 'user':
            # Get current username
            self.object = getpass.getuser()
        else:
            # Get short hostname in upper case with trailing $
            self.object = socket.gethostname().split('.', 1)[0].upper() + "$"

    def verbose( self, s ):
        """Print string if verbose level set"""
        if self.is_verbose or self.is_debug:
            print( s )

    def debug( self, s ):
        """Print string if debug level set"""
        if self.is_debug:
            print( s )

    def get_gpo_list( self ):
        """Get GPO for user or machine"""
        self.debug( 'get_gpo_list()' )
        run_command = [ 'net', 'ads', 'gpo', 'list', self.object ]
        self.debug( "Run command: %s" % ( " ".join( run_command ) ) )
        p = subprocess.Popen( run_command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True )
        output = p.stdout.read().decode()
        self.debug( output )
        # Parse output of net ads gro list
        r = re.compile( '^[^ \t]+:' )
        i = None
        for l in list( filter( r.match, output.splitlines() ) ):
            ( param, value ) = re.split( ':[ \t]*', l, maxsplit=1 )
            #self.debug( '%s|%s' % ( param, value ) )
            if param == 'name':
                i = { 'name': value, 'description': '', 'filepath': '' }
                self.list.append( i )
            elif param == 'displayname' and i:
                i['description'] = value
            elif param == 'filesyspath' and i:
                i['filepath'] = value

    def apply(self):
        """Perform apply policies"""
        self.debug( 'apply()' )
        self.verbose( "Apply domain policies for %s '%s'..." % ( self.c, self.object ) )
        self.get_gpo_list()
        for p in self.list:
            self.verbose( "Applying %s (%s) from %s" % ( p['name'], p['description'], p['filepath'] ) )
            # TODO

# Read command-line parameters
parser = argparse.ArgumentParser(
    description='Script for apply ALT Domain Policies',
    formatter_class=argparse.RawDescriptionHelpFormatter )

parser.add_argument( '-v', action='store_true', dest='verbose',   help='Verbose output' )
parser.add_argument( '-d', action='store_true', dest='debug',     help='Debug output' )
parser.add_argument( 'policy_class', choices=['user', 'machine'], help='Class of policies: user or machine' )
parser.add_argument( 'object', nargs='?', help='Name of user or machine (optional)' )
parser.add_argument( '--version', action='version', version=VERSION )

args = parser.parse_args()

# Apply policies
m = DomainPolicies( args.policy_class, args.verbose, args.debug, args.object )
m.apply()
