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

from enum import Enum
import socket
import logging
import os
import re
import sys
import subprocess
from .policy import Policy
import sqlite3
import adp.config
import shutil
import getpass
import grp
import tempfile

class GPOObjectType( Enum ):
    UNKNOWN = 0
    USER = 1
    MACHINE = 2

class GPOListCache:
    """Class for GPO list cache"""
    def __init__( self, name ):
        self.name = name
        if adp.config.configuration != None:
            self.filename = adp.config.configuration.CACHED_LIST
        else:
            logging.fatal( "Unable to read configuration" )
            sys.exit( 1 )

    def write( self, list ):
        """Write list of Policy into sqlite3 database"""
        logging.info( "Write cached list for %s to %s" % ( self.name, self.filename ) )
        
        # Create database if it is not exist
        need_create_table = not os.path.isfile( self.filename )

        # Open database
        conn = sqlite3.connect( self.filename )
        cursor = conn.cursor()

        # Create table for new database
        if need_create_table:
            # Table for track GPO for objects
            cursor.execute("""CREATE TABLE gpo_list (
                subject text,
                id text,
                name text,
                location text
               )""")
            # Table for execution results
            cursor.execute("""CREATE TABLE policy_run (
                timestamp integer,
                subject text,
                policy text,
                template text,
                version text,
                code text
               )""")

        # Remove old records for self.name
        cursor.execute( "DELETE FROM gpo_list WHERE subject=?", ( self.name, ) )
        conn.commit()

        # Put list into database
        for i in list:
            cursor.execute( "INSERT INTO gpo_list VALUES(?,?,?,?)", ( self.name, i.id, i.name, i.location, ) )
            conn.commit()

        # Set permissions writeable for group `users`
        os.chown( self.filename, 0, grp.getgrnam('users')[2] )
        os.chmod( self.filename, 660 )

    def read( self ):
        """Read list of Policy from sqlite3 database"""
        logging.info( "Read cached list for %s from %s" % ( self.name, self.filename, ) )
        list = []

        # Open databse
        conn = sqlite3.connect( self.filename )
        cursor = conn.cursor()
        for i in cursor.execute( "SELECT id, name, location from gpo_list WHERE subject=?", ( self.name, ) ):
            p = Policy()
            ( p.id, p.name, p.location ) = i
            list.append( p )
        
        return list

class GPOList:
    """Class for GPO list"""
    def __init__( self, name=None, object_type=GPOObjectType.UNKNOWN ):
        self.list = []
        self.object_name = name
        self.object_type = object_type
        self.type_dir = ''
        cfg = adp.config.configuration

        # Autodetect object_name if it is empty
        if not self.object_name:
            if os.geteuid() == 0:
                # Root privileges: this is machine name
                self.object_name = socket.gethostname().split('.', 1)[0].upper() + '$'
            else:
                self.object_name = getpass.getuser()

        # Detect object_type
        if self.object_type == GPOObjectType.UNKNOWN:
            if self.object_name[-1:] == '$':
                # Machine name ends with $
                self.object_type = GPOObjectType.MACHINE
                self.type_dir = 'Machine'
            else:
                self.object_type = GPOObjectType.USER
                self.type_dir = 'User'

        # Fill obect information to config
        if cfg:
            cfg.object_name = self.object_name
            cfg.object_type = self.type_dir

        # Object name should be not empty
        if not self.object_name:
            sys.exit( 1 )

        # Create cache for object
        self.cache = GPOListCache( self.object_name )

    def sync_templates( self ):
        """Sync from //dc/sysvol/domain-name/templates to /usr/libexec/adp/"""
        if os.geteuid() != 0:
            logging.error( "Unable to sync templates without root permissions" )
            return 1

        tmp = tempfile.mkdtemp()
        cfg = adp.config.configuration
        if cfg == None:
            logging.fatal( "Unable to read configuration" )
            return 1
        server = cfg.dc
        share = 'sysvol'
        connection = "//%s/%s" % ( server, share )
        
        l_path = cfg.TEMPLATE_PATH + '/'
        r_path = os.path.join( tmp, cfg.domain, 'templates' ) + '/'

        # mount -t cifs //dc0.alt.domain/sysvol /tmp/aa -o sec=krb5,ro
        cmd = [ 'mount', '-t', 'cifs', connection, tmp, '-o', 'sec=krb5,ro' ]
        logging.debug( ''.join( cmd ) )
        output = subprocess.check_output( cmd, stderr=subprocess.STDOUT ).decode()

        # rsync content
        if os.path.isdir( r_path ):
            cmd = [ 'rsync', '-vaP', '--delete', r_path, l_path ]
            logging.debug( ''.join( cmd ) )
            output = subprocess.check_output( cmd, stderr=subprocess.STDOUT ).decode()
            logging.debug( output )

        # Umount share
        output = subprocess.check_output( [ 'umount', tmp ], stderr=subprocess.STDOUT ).decode()

    def fill( self ):
        """Get GPO list for object"""
        # Read list from cache
        self.list = self.cache.read()

    def fill_from_server( self ):
        """Get GPO list for specified object: user or machine from server and put into cache"""
        # Get GPO list by net ads gpo list command
        run_command = [ 'net', 'ads', 'gpo', 'list', self.object_name ]
        logging.debug( "Run command: %s" % ( " ".join( run_command ) ) )
        p = subprocess.Popen( run_command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL, close_fds=True )
        output = p.stdout.read().decode()
        logging.debug( output )
        # Parse output of net ads gro list
        r = re.compile( '^[^ \t]+:' )
        i = None
        for l in list( filter( r.match, output.splitlines() ) ):
            ( param, value ) = re.split( ':[ \t]*', l, maxsplit=1 )
            if param == 'name':
                i = Policy( value )
                self.list.append( i )
            elif param == 'displayname' and i:
                i.name = value
            elif param == 'filesyspath' and i:
                i.location = value

        # Add mandatory hidden postscript policy
        postscript = Policy( 'postscript' )
        postscript.name = 'postscript'
        self.list.append( postscript )

        # Sync policies from server to cached dir
        cfg = adp.config.configuration
        if cfg == None:
            logging.fatal( "Unable to read configuration" )
            sys.exit( 1 )
        server = cfg.dc
        share = 'sysvol'
        connection = "//%s/%s" % ( server, share )
        new_list = []
        for pol in self.list:

            # Check if pol.location is empty
            if pol.location == '(null)':
                pol.location = ''
                continue

            # Remove cached policy directory, create empty directory and change directory
            l_path = os.path.join( cfg.CACHED_DIR, pol.id, self.type_dir )
            logging.info( "Cache policy content to %s" % ( l_path ) )
            shutil.rmtree( l_path, ignore_errors=True )
            os.makedirs( l_path )
            os.chdir( l_path ) 

            try:
                # Download only Linux.xml in User or Machine subdirectory of policy by smbclient
                r_path = os.path.join( cfg.domain, 'Policies', pol.id, self.type_dir )
                r_file = "Linux.xml"
                logging.debug( "Sync from %s/%s/%s to %s" % ( connection, r_path, r_file, l_path ) )
                cmd = [ 'smbclient', '-N', '-k', connection, '-c', "prompt OFF;cd %s;get %s" % ( r_path.replace( '/', '\\' ), r_file ) ]
                logging.debug( ' '.join( cmd ) )
                ret = subprocess.call( cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, stdin=subprocess.DEVNULL )
                if ret != 0:
                    raise Exception( 'Error fetch: %d, policy %s is ignored' % ( ret, pol.id ) )
                else:
                    logging.debug( "Saved %s/%s (%d bytes)" % ( l_path, r_file, os.stat( r_file ).st_size ) )
            except Exception as e:
                # Error cache policy - remove from list
                logging.error( "Unable to cache %s: %s" % ( l_path, e ) )
                continue

            # Store cached dir to Policy object
            pol.location = l_path

            # Cached policy is store to new_list
            new_list.append( pol )

        # Put new_list in cache
        self.list = new_list
        self.cache.write( self.list )

    def apply( self ):
        """Apply GPO for object"""
        logging.debug( "Apply policies for %s" % ( self.object_name ) )

        # Put policies to log
        for i in self.list:
            logging.debug( "  %s (%s)" % ( i.id, i.name ) )

        # Apply each policy
        for i in self.list:
            i.apply()
