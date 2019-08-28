#!/usr/bin/env python3

import sys
import csv

reader = csv.reader(sys.stdin, dialect='excel-tab')
writer = csv.writer(sys.stdout, quoting=csv.QUOTE_ALL)

for lineno, row in enumerate(reader):
    if lineno == 0:
        continue  # skip header

    recid = row[0]
    orig260c = row[1]
    new260c_from = row[4]
    new260c_till = row[5]

    key = recid + "/" + orig260c
    val = new260c_from
    
    if new260c_till:
        val += "-" + new260c_till

    # skip trivial cases (already handled by conversion)    
    if orig260c == val:
        continue

    if orig260c == val + ".":
        continue

    if orig260c == val + "-":
        continue

    if orig260c == val + "-.":
        continue

    if orig260c == "[" + val + "]":
        continue

    if orig260c == "[" + val + "].":
        continue

    
    writer.writerow([key, val])
