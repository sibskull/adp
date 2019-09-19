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
import xml.etree.ElementTree as ET

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

        # Get Kerberos ticket for machine
        if self.c == 'machine':
            subprocess.call( [ 'kinit', '-k', self.object ] )

        try:
            # Check Kerberos ticket by `klist -s`
            subprocess.check_call( [ 'klist', '-s' ] )
            logging.debug( subprocess.check_output( 'klist', stderr=subprocess.STDOUT ).decode() )
        except:
            logging.fatal( 'There is no Kerberos ticket' )
            sys.exit( 1 )

        # Get GPO list by net ads gpo list command
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

        # Mount share
        sysvol_share = "smb://%s/sysvol" % ( os.environ['ADP_DOMAIN'] )
        try:
            logging.debug( "Mount %s" % ( sysvol_share ) )
            output = subprocess.check_output( [ 'gio', 'mount', sysvol_share ], stderr=subprocess.STDOUT ).decode()
            logging.debug( output )
        except:
            pass

        for p in self.list:
            logging.debug( "Get %s (%s) from %s" % ( p['name'], p['description'], p['filepath'] ) )
            # Get Linux.xml from filepath as string
            adp_policy_path = "smb:%s" % ( p['filepath'].replace( '\\', '/' ) )
            adp_policy_file = "%s/Linux.xml" % ( adp_policy_path )
            try:
                policy_content = subprocess.check_output( [ 'gio', 'cat', adp_policy_file ], stderr=subprocess.DEVNULL ).decode()
                logging.debug( policy_content )
            except:
                pass

            if policy_content == '':
                logging.debug( "GPO %s does not contains Linux.xml, ignoring..." % ( p['name'] ) )
                continue

            # Set path to ADP_PATH environment variable
            os.environ['ADP_PATH'] = adp_policy_path

            # Parse policy content
            try:
                t = ET.fromstring( policy_content )
            except:
                logging.error( "Unable to parse policy file %s" % ( adp_policy_file ) )
                continue

            logging.info( "Apply policy %s" % ( p['name'] ) )

            # Iterate through policies
            for policy in t.findall( 'policy' ):
                # Get template name
                template = policy.find( 'template' ).text
                # Fill arguments
                args = []
                for i in policy.findall( 'param' ):
                    args.append( i.text )

                # Apply policy
                if template != '':
                    logging.info( "Apply rule %s" % ( template ) )
                    apply_policy( template, args, self.c )

        # Umount share
        try:
            logging.debug( "Umount %s" % ( sysvol_share ) )
            output = subprocess.check_output( [ 'gio', 'mount', '-u', sysvol_share ], stderr=subprocess.STDOUT ).decode()
            logging.debug( output )
        except:
            pass

def env_set_domain():
    """Get current Active Directory domain name"""
    # Get domain name by command net ads lookup
    try:
        output = subprocess.check_output( 'net ads lookup', stderr=subprocess.STDOUT ).decode()
    except:
        return
    # Parse ^Domain:...
    d = re.search( "Domain:\s*(\S+)\n", output, re.MULTILINE )
    if d:
        os.environ['ADP_DOMAIN'] = d.group(1)
        logging.debug( "ADP_DOMAIN=%s" % ( d.group(1) ) )

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

def apply_policy( template, args, class_name=None ):
    """Apply local policy"""
    if not template:
        print( "Please, specify template name" )
        sys.exit( 1 )

    # Get file name of specified template and open it
    file_name = "%s/%s.xml" % ( TEMPLATE_PATH, template )
    logging.debug( "Open template from %s" % ( file_name ) )
    if not os.path.exists( file_name ):
        logging.error( "File %s does not exist" % ( file_name ) )
        return 1
    try:
        t = ET.parse( file_name )
    except:
        logging.error( "Unable to parse %s" % ( file_name ) )
        return 1

    # TODO Check class from <class> tag
    # TODO Check requirements from <requires> tag(s)
    script = t.find( "script" )
    if script != None and script.text:
        script_file = "%s/scripts/%s" % ( TEMPLATE_PATH, script.text )
        # TODO put domain name and share path to environment variables

        # TODO Check arguments
        a = args
        a.insert(0, script_file )

        # Run script
        logging.debug( "Run script %s" % ( ' '.join( a ) ))
        p = subprocess.Popen( a, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL, close_fds=True )
        output = p.stdout.read().decode()
        logging.debug( output )
    return 0


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

# Set domain in ADP_DOMAIN environment variable
env_set_domain()

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

