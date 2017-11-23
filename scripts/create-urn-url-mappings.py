#!/usr/bin/env python

"""Read an N-Triple file on stdin, produce an XML file on stdout with URN to URL mappings for the URN.fi resolver."""

import sys

seen = set()


def emit_header():
    print """<?xml version="1.0" encoding="ASCII"?>
<records xmlns="urn:nbn:se:uu:ub:epc-schema:rs-location-mapping" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:nbn:se:uu:ub:epc-schema:rs-location-mapping http://urn.kb.se/resolve?urn=urn:nbn:se:uu:ub:epc-schema:rs-location-mapping&amp;godirectly">
 <protocol-version>3.0</protocol-version>"""


def emit_mapping(urn, url):
    print """<record>
  <header>
    <identifier>%s</identifier>
    <destinations>
      <destination status="activated">
        <url>%s</url>
      </destination>
    </destinations>
  </header>
</record>""" % (urn, url)

def emit_footer():
    print "</records>"

emit_header()

for line in sys.stdin:
    s,p,o = line.split(None, 2)
    if p != '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>':
        continue
    s = s[1:-1] # strip brackets
    if s in seen:
        continue
    if not s.startswith('http://urn.fi/URN:NBN:fi:bib:me:'):
        continue
    seen.add(s)
    urn = s.replace('http://urn.fi/', '')
    url = urn.replace('URN:NBN:fi:bib:me:', 'http://data.nationallibrary.fi/bib/me/')
    emit_mapping(urn, url)

emit_footer()
