[![Build Status](https://travis-ci.org/NatLibFi/bib-rdf-pipeline.svg?branch=master)](https://travis-ci.org/NatLibFi/bib-rdf-pipeline)

# bib-rdf-pipeline

This repository contains various scripts and configuration for converting MARC bibliographic records into RDF, for use at the National Library of Finland.

The main component is a conversion pipeline driven by a Makefile that defines rules for realizing the conversion steps using command line tools.

The steps of the conversion are:

1. Start with a file of MARC records in Aleph sequential format
2. Split the file into smaller batches
3. Preprocess using unix tools such as grep and sed, to remove some local peculiarities
4. Convert to MARCXML and enrich the MARC records, using Catmandu
5. Run the Library of Congress marc2bibframe2 XSLT conversion from MARC to BIBFRAME RDF
6. Convert the BIBFRAME RDF/XML data into N-Triples format and fix up some bad URIs
6. Calculate work keys (e.g. author+title combination) used later for merging data about the same creative work
7. Convert the BIBFRAME data into Schema.org RDF in N-Triples format
8. Reconcile entities in the Schema.org data against external sources (e.g. YSA/YSO, Corporate names authority, RDA vocabularies)
9. Merge the Schema.org data about the same works
10. Calculate agent keys used for merging data about the same agent (person or organization)
11. Merge the agents based on agent keys
12. Convert the raw Schema.org data to HDT format so the full data set can be queried with SPARQL from the command line
13. Consolidate the data by e.g. rewriting URIs and moving subjects into the original work
14. Convert the consolidated data to HDT
15. ??? (TBD)
16. Profit!

# Dependencies

Command line tools are assumed to be available in `$PATH`, but the paths can be overridden on the make command line, e.g. `make CATMANDU=/opt/catmandu`

## For running the main suite

* [Apache Jena](http://jena.apache.org/) command line utilities `sparql` and `rsparql`
* [Catmandu](http://librecat.org/Catmandu/) utility `catmandu`
* `uconv` utility from Ubuntu package `icu-devtools`
* `xsltproc` utility from Ubuntu package `xsltproc`
* [hdt-cpp](https://github.com/rdfhdt/hdt-cpp) command line utilities `rdf2hdt` and `hdtSearch`
* [hdt-java](https://github.com/rdfhdt/hdt-java) command line utility `hdtsparql.sh`

## For running the unit tests

In addition to above:

* [bats](https://github.com/sstephenson/bats) in $PATH
* `xmllint` utility from Ubuntu package `libxml2-utils` in $PATH
