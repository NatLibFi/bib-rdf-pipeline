#!/usr/bin/env python

# Processes an Aleph sequence and filters away inappropriate duplicate
# MARC fields including 001 and 005.

import sys
import re

FIELDS=['LDR','001','005','100','245']
seen = set()

for line in sys.stdin:
    recid = line[:9]
    fld = line[10:13]
    # only one of 100,110,111 should exist
    fld = fld.replace('110','100')
    fld = fld.replace('111','100')
    if fld in FIELDS:
        tag = (recid, fld)
        if tag in seen:
            continue # skip
        seen.add(tag)
    # filter inappropriately duplicated $$2 subfields
    line = re.sub(r'(\$\$2[^\$]*)+', r'\1', line)
    print line,
