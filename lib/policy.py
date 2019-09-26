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
import os
import re
import sys
import subprocess
import adp.config
import xml.etree.ElementTree as ET

class Policy:
    """Class for policy instance"""
    def __init__( self, id='' ):
        self.id = id
        self.name = ''
        self.location = ''

    def apply( self ):
        """Apply policy"""
        logging.info( "Applying '%s' (%s)" % ( self.name, self.id ) )
        
        # Put domain name to environment variable
        cfg = adp.config.configuration
        if cfg == None:
            return
        os.environ[ 'ADP_DOMAIN' ] = cfg.domain

        # Change working dir to self.location
        if self.location == '':
            logging.debug( "Ignored policy %s without cached directory" % ( self.id ) )
            return

        # Check for User, user or USER directory
        ( top_dir, last_part ) = os.path.split( self.location )
        loc = self.location
        if not os.path.isdir( loc ):
            # Possible, last part in path has wrong case
            loc = os.path.join( top_dir, last_part.upper() )
            if not os.path.isdir( loc):
                loc = os.path.join( top_dir, last_part.lower() )
                if not os.path.isdir( loc):
                    logging.error( "Unable to find cached policy dir %s" % ( loc ) )
                    return
        self.location = loc
        os.chdir( loc )

        # Check for Linux.xml
        if not os.path.isfile( 'Linux.xml' ):
            logging.debug( "GPO %s does not contains Linux.xml, policy is ignored" % ( self.id ) )
            return

        # Parse policy content
        try:
            t = ET.parse( 'Linux.xml' )
        except Exception as e:
            logging.error( "Unable to parse policy file Linux.xml: %s" % ( e ) )
            return

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
                logging.info( "Apply policy with template %s" % ( template ) )
                self.execute_local_template( template, args )

    def execute_local_template( self, template, args ):
        """Apply local policy"""                                                                                           
        if not template:
            logging.fatal( "Please, specify template name" )
            sys.exit( 1 )

        cfg = adp.config.configuration
        if cfg != None:
            sys.exit( 1 )

        # Get file name of specified template and open it
        file_name = "%s/%s.xml" % ( cfg.TEMPLATE_PATH, template )
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
            script_file = "%s/scripts/%s" % ( cfg.TEMPLATE_PATH, script.text )
            # TODO Check arguments
            a = args
            a.insert(0, script_file )

            # Run script
            logging.debug( "Run script %s" % ( ' '.join( a ) ))
            p = subprocess.Popen( a, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL, close_fds=True )
            output = p.stdout.read().decode()
            logging.debug( output )
        return 0
