#!/usr/bin/env python

import re
import sys

# Attempts to parse N-Triples from stdin using an approximation of the N-triples grammar.
# Valid triples are passed through to stdout.
# Warning messages about bad triples are output on stderr.
#
# Currently unchecked cases (TODO):
# - detailed checking of language tags and datatypes
# - checking of valid/invalid characters in blank node identifiers

IRIREF = r'<[^\x00-\x20<>"{}|^`\\]*>'
BNODE = r'_:\S+'
LITERAL = r'".*"\S*'
TRIPLE = '(%s|%s) %s (%s|%s|%s) .' % (IRIREF, BNODE, IRIREF, IRIREF, LITERAL, BNODE)
TRIPLE_RE = re.compile(TRIPLE)

for line in sys.stdin:
    if TRIPLE_RE.match(line):
        print line,
    else:
        print >>sys.stderr, "SYNTAX ERROR, skipping:", line,
    
