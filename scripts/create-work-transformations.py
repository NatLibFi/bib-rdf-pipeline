#!/usr/bin/env python

import re
import sys


keys_for_uri = {}
uris_for_key = {}

for line in sys.stdin:
    s,p,o = line.split(None, 2)
    uri = s[1:-1]
    key = o.split('"')[1]
    keys_for_uri.setdefault(uri, [])
    keys_for_uri[uri].append(key)
    uris_for_key.setdefault(key, [])
    uris_for_key[key].append(uri)

def traverse_uris(uri):
    """return all the URIs that directly or indirectly share keys with the given URI"""
    seen = set()
    uris_to_check = [uri]
    while len(uris_to_check) > 0: 
        uri = uris_to_check.pop()
        if uri not in seen:
            seen.add(uri)
            for key in keys_for_uri[uri]:
                for uri2 in uris_for_key[key]:
                    if uri2 not in seen:
                        uris_to_check.append(uri2)
                    
    return seen

def uri_sort_key(uri):
    """return a sort key for the given URI which takes into account originating MARC field"""
    field = uri.split('#Work')[1][:3] # may be '' when field is nonexistent
    # determine priority based on MARC field
    if field == '': # Work for record itself has highest priority
        priority = 0
    elif field == '765': # 765 (original of translation) has  second highest priority
        priority = 1
    else:
        priority = int(field) # for the rest, use the field number as priority value
    return (priority, uri)

def select_uri(uris):
    """return the most appropriate URI from the given set of URIs"""
    return sorted(uris, key=uri_sort_key)[0]

uri_replacement = {} # cache for storing already computed replacements

for uri in keys_for_uri.keys():
    if uri not in uri_replacement:
        uris = traverse_uris(uri)
        if len(uris) > 1:
            replacement = select_uri(uris)
            for uri2 in uris: # store in cache for all URIs in the merged set
                uri_replacement[uri2] = replacement
    if uri in uri_replacement and uri_replacement[uri] != uri:
        print "<%s> <http://schema.org/sameAs> <%s> ." % (uri, uri_replacement[uri])
