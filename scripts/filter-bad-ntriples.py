#!/usr/bin/env python

import re
import sys
import urllib

# Attempts to parse N-Triples from stdin using an approximation of the N-triples grammar.
# Valid triples are passed through to stdout.
# Some special characters in IRIs are escaped, repairing the IRI if possible.
# Warning messages about bad triples are output on stderr.
#
# Currently unchecked cases (TODO):
# - detailed checking of language tags and datatypes
# - checking of valid/invalid characters in blank node identifiers
# - lines with comments will be rejected even though they may be valid

IRIREF = r'<[^\x00-\x20<>"{}|^`\\]*>'
BNODE = r'_:\S+'
LITERAL = r'".*"\S*'
TRIPLE = '(%s|%s)\s+%s\s+(%s|%s|%s)\s.' % (IRIREF, BNODE, IRIREF, IRIREF, LITERAL, BNODE)
TRIPLE_RE = re.compile(TRIPLE)
QUOTE = r'[{}|^`\\]'
QUOTE_RE = re.compile(QUOTE)

def quote(match):
    return urllib.quote(match.group(0))


for line in sys.stdin:
    if TRIPLE_RE.match(line):
        print line,
    else:
        quoted = QUOTE_RE.sub(quote, line)
        if TRIPLE_RE.match(quoted):
            print >>sys.stderr, "SYNTAX ERROR, quoting: ", line,
            print quoted,
        else:
            print >>sys.stderr, "SYNTAX ERROR, skipping:", line,
    
