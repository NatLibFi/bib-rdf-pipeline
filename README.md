# bib-rdf-pipeline

This repository contains various scripts and configuration for converting MARC bibliographic records into RDF, for use at the National Library of Finland.

The main component is a conversion pipeline driven by a Makefile that defines rules for realizing the conversion steps using command line tools.

The steps of the conversion are:

1. Fetch the input data in Aleph sequential format
2. Split the file into smaller batches
3. Preprocess using unix tools such as grep and sed, to remove some local peculiarities
4. Convert to MARCXML and enrich the MARC records, using Catmandu
5. Run the Library of Congress marc2bibframe XQuery conversion from MARC to BIBFRAME RDF, using marc2bibframe-wrapper
6. Postprocess the RDF output using unix tools to fix some bad RDF/XML syntax
7. ??? (TBD)
8. Profit!

