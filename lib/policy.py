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
import adp.config
import xml.etree.ElementTree as ET
from adp.template import Template

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
            # Get policy version
            v = policy.find( 'version' )
            if v != None:
                version = v.text
            else:
                version = ''
            # Fill arguments
            args = {}
            for i in policy.findall( 'param' ):
                param_name = i.attrib.get( 'name', 'param' )
                args[ param_name ] = i.text

            # Apply policy
            logging.info( "Apply policy with template %s" % ( template ) )
            t = Template( template )
            result = t.execute( args )

            # Put result to database
            if cfg.cache != None:
                cfg.cache.log_result( self.name, template, version, result )
