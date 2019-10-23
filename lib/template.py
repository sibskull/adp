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
import glob

class Template:
    """Class for policy template"""
    def __init__( self, template='' ):
        self.template = template

    def list( self ):
        """Get templates list"""

        # Get global configuration
        cfg = adp.config.configuration
        if cfg == None:
            return []

        # Get list of file in template directory
        logging.debug( "Get templates from %s" % ( cfg.TEMPLATE_PATH ) )
        files = [ os.path.basename( os.path.splitext( f )[0] ) for f in glob.glob( cfg.TEMPLATE_PATH + "/*.xml", recursive=False ) ]
        return files

    def content( self ):
        """Return template content"""

        if self.template == '':
            logging.fatal( "Please, specify template name" )
            sys.exit( 1 )

        # Get global configuration
        cfg = adp.config.configuration
        if cfg == None:
            sys.exit( 1 )

        path = "%s/%s.xml" % ( cfg.TEMPLATE_PATH, self.template )
        logging.debug( "Get template content from file %s" % ( path ) )
        content = ''
        try:
            with open( path, 'r' ) as f:
                content = f.read()
        except:
            logging.fatal( "Unable to open template '%s'" % ( self.template ) )

        return content

    def execute( self, args={} ):
        """Execute local template with specified arguments"""                                                                                           
        if self.template == '':
            logging.fatal( "Please, specify template name" )
            sys.exit( 1 )

        # Get global configuration
        cfg = adp.config.configuration
        if cfg == None:
            sys.exit( 1 )

        # Fix passed None as args
        if args == None:
            args = []

        # Get file name of specified template and open it
        file_name = "%s/%s.xml" % ( cfg.TEMPLATE_PATH, self.template )
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
            a = [ script_file ]

            # Get arguments from template
            for p in t.findall( "parameters/param" ):
                if 'name' in p.attrib:
                    name = p.attrib['name']
                else:
                    name = p.text
                if 'type' in p.attrib:
                    type = p.attrib['type']
                else:
                    type = p.text
                default = p.attrib['default'] if 'default' in p.attrib else ''

                # Fill real values from passed parameters
                val = args.get( name, default )

                # Check type of boolean values
                if type == 'boolean':
                    if val == 'on' or val == 'true':
                        val = 'true'
                    else:
                        val = 'false'

                a.append( val )

            # Run script
            logging.debug( "Run script %s" % ( ' '.join( a ) ))
            p = subprocess.Popen( a, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL )
            output = p.stdout.read().decode()
            p.wait()
            logging.debug( "Return code %d: %s" % ( p.returncode, output ) )
            return p.returncode
        return 0
