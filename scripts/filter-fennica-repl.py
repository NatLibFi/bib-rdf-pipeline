#!/usr/bin/env python

import re
import sys

# Filters Fennica records from Melinda, applying Fennica replication rules
# as documented here:
# https://www.kiwi.fi/display/MELFENNI/Fennican+replikointiasetukset
#
# Input: Aleph sequence on stdin
# Output: Aleph sequence on stdout

# These fields will be removed unless tagged with $9FENNI<KEEP>
REMOVE_UNLESS_KEEP_TAGGED = set([
    '010', '013', '016', '017', '018', '025', '026', '027', '030', '031', '032', '037', '038', '043', '046', '047', '048', '049', '050', '051', '052', '055', '060', '061', '070', '071', '072', '074', '082', '083', '085', '086',
    '242', '257', '258', '270',
    '306', '307', '340', '342', '343', '345', '346', '351', '352', '355', '357', '363', '365', '366', '377', '380', '381', '382', '383', '384', '385', '386',
    '501', '507', '513', '514', '521', '522', '524', '526', '535', '536', '540', '541', '544', '545', '547', '552', '555', '556', '561', '562', '563', '565', '567', '581', '584', '585',
    '751', '752', '753', '754', '774', '786',
    '811', '850', '882', '883', '886', '887',
    '908', '940',
    
    '080', '084',
    '600', '610', '611', '630', '648', '650', '651', '653', '654', '655', '656', '657', '658', '662',
    '502', '504', '505', '506', '506 510', '511', '515', '518', '520', '530', '534', '538', '546', '550', '580', '588',
    '760', '762', '765', '767', '770', '772', '773', '774', '775', '776', '777', '780', '785', '786', '787',
    '960'
])

# These fields will be removed unless tagged with $5FENNI or $5FI-NL
REMOVE_UNLESS_FENNI_TAGGED = set([
    '583', '594', '901', '902', '903', '904', '905', '906', '935'
])

# These fields will always be removed
REMOVE_ALWAYS = set([
    '599', '852',
    '036',
    'CAT', 'LOW', 'SID'
])


KEEP = re.compile(r'\$\$9FENNI<KEEP>')
DROP = re.compile(r'\$\$9FENNI<DROP>')
FENNI = re.compile(r'\$\$5(FENNI|FI-NL)')
OTHERTAG = re.compile(r'\$\$9\w+<(KEEP|DROP)>')

for line in sys.stdin:
    if DROP.search(line) is not None:
        # found DROP tag, skipping field
        continue
    
    fld = line[10:13]
    
    if fld in REMOVE_ALWAYS:
        # skip field that should always be removed
        continue
    
    if fld in REMOVE_UNLESS_KEEP_TAGGED:
        if KEEP.search(line) is None:
            # no KEEP tag found, skipping field
            continue
        # KEEP tag found, remove it
        line = KEEP.sub('', line)
    if fld in REMOVE_UNLESS_FENNI_TAGGED:
        if FENNI.search(line) is None:
            # no FENNI tag found, skipping field
            continue
        # FENNI tag found, remove it
        line = FENNI.sub('', line)
    
    # remove other tags
    line = OTHERTAG.sub('', line)
    
    print line,
