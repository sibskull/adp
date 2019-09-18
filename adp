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
import os
import glob
import logging

VERSION = '0.1'
TEMPLATE_PATH="/usr/libexec/adp"
LOG_DIR="/var/log/adp/"
log_level = logging.ERROR

class DomainPolicies:
    """Class for get GPO for specified policy class and apply they"""
    def __init__( self, t, obj=None ):
        self.list = []
        self.c = t
        if obj:
            self.object = obj
        elif self.c == 'user':
            # Get current username
            self.object = getpass.getuser()
        else:
            # Get short hostname in upper case with trailing $
            self.object = socket.gethostname().split('.', 1)[0].upper() + "$"
        logging.basicConfig( filename = LOG_DIR + self.object, format = '%(asctime)s %(message)s', level = log_level )

    def get_gpo_list( self ):
        """Get GPO for user or machine"""
        logging.debug( 'get_gpo_list()' )
        # TODO Check Kerberos ticket by `klist -s`
        run_command = [ 'net', 'ads', 'gpo', 'list', self.object ]
        logging.debug( "Run command: %s" % ( " ".join( run_command ) ) )
        p = subprocess.Popen( run_command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL, close_fds=True )
        output = p.stdout.read().decode()
        logging.debug( output )
        # Parse output of net ads gro list
        r = re.compile( '^[^ \t]+:' )
        i = None
        for l in list( filter( r.match, output.splitlines() ) ):
            ( param, value ) = re.split( ':[ \t]*', l, maxsplit=1 )
            #logging.debug( '%s|%s' % ( param, value ) )
            if param == 'name':
                i = { 'name': value, 'description': '', 'filepath': '' }
                self.list.append( i )
            elif param == 'displayname' and i:
                i['description'] = value
            elif param == 'filesyspath' and i:
                i['filepath'] = value

    def apply(self):
        """Perform apply policies"""
        logging.debug( 'apply()' )
        logging.info( "Apply domain policies for %s '%s'..." % ( self.c, self.object ) )
        self.get_gpo_list()
        for p in self.list:
            logging.info( "Applying %s (%s) from %s" % ( p['name'], p['description'], p['filepath'] ) )
            # TODO

# Functions
def list_templates():
    """List all available local policy templates"""
    files = [ f for f in glob.glob( TEMPLATE_PATH + "/*.xml", recursive=False ) ]
    for f in files:
        print( os.path.basename( os.path.splitext( f )[0] ) )

def show_template( template ):
    """Show local policy template detail"""
    if not template:
        print( "Please, specify template name" )
        sys.exit( 1 )

    path = "%s/%s.xml" % ( TEMPLATE_PATH, template )
    try:
        with open( path, 'r' ) as f:
            print( f.read() )
    except:
        print( "Unable to open template '%s'" % ( template ) )
        sys.exit( 1 )

def apply_policy( template, args ):
    """Apply local policy"""
    if not template:
        print( "Please, specify template name" )
        sys.exit( 1 )

    # TODO

# Read command-line parameters
parser = argparse.ArgumentParser(
    description='Script for apply ALT Domain Policies',
    formatter_class=argparse.RawDescriptionHelpFormatter )

parser.add_argument( '-v', action='store_true', dest='verbose',   help='Verbose output' )
parser.add_argument( '-d', action='store_true', dest='debug',     help='Debug output' )
parser.add_argument( 'command', choices=['user', 'machine', 'list', 'show', 'apply' ], help='Class of policies: user or machine, list local templates, show template or apply local policy' )
parser.add_argument( 'object', nargs='?', help='Name of user, machine or template (optional)' )
parser.add_argument( 'args', nargs='*', help='Arguments for apply command (optional)' )
parser.add_argument( '--version', action='version', version=VERSION )

args = parser.parse_args()

# Logging
if args.verbose:
    log_level = logging.INFO
if args.debug:
    log_level = logging.DEBUG

# Process command
if args.command == 'list':
    logging.basicConfig( format = '%(message)s', level = log_level )
    list_templates()
elif args.command == 'show':
    logging.basicConfig( format = '%(message)s', level = log_level )
    show_template( args.object )
elif args.command == 'apply':
    logging.basicConfig( format = '%(message)s', level = log_level )
    apply_policy( args.object, args.args )
else:
    # Apply policies
    m = DomainPolicies( args.command, args.object )
    m.apply()

