# Paths to non-unix-standard tools that we depend on; can be overridden on the command line

CATMANDU=catmandu
MARC2BIBFRAME=$(PATH_PREFIX)../marc2bibframe
MARC2BIBFRAMEWRAPPER=$(PATH_PREFIX)../marc2bibframe-wrapper/target/marc2bibframe-wrapper-*.jar
RAPPER=rapper
RSPARQL=rsparql
RIOT=riot
SPARQL=sparql
UCONV=uconv
RDF2HDT=rdf2hdt
HDTSEARCH=hdtSearch
HDTSPARQL=hdtsparql.sh

# Other configuration settings
FINTOSPARQL=http://api.dev.finto.fi/sparql
URIBASEFENNICA=http://urn.fi/URN:NBN:fi:bib:fennica:
JVMARGS="-Xmx2G"

# Pattern rules used internally

split-input/%.md5: input/%.alephseq
	scripts/split-input.sh $(patsubst %.md5,%,$@) <$^
	cd split-input; md5sum $(patsubst split-input/%.md5,%,$@)-*.alephseq >`basename $@`

%.md5: %
	md5sum $^ >$@

slices/%.md5: split-input/%.md5
	scripts/update-slices.sh $^ $@

refdata/iso639-2-fi.csv: sparql/extract-iso639-2-fi.rq
	$(RSPARQL) --service $(FINTOSPARQL) --query $^ --results=CSV >$@

refdata/iso639-1-2-mapping.nt: sparql/extract-iso639-1-2-mapping.rq
	$(RSPARQL) --service $(FINTOSPARQL) --query $^ --results=NT >$@

refdata/ysa-skos-labels.nt: sparql/extract-ysa-skos-labels.rq
	$(RSPARQL) --service $(FINTOSPARQL) --query $^ --results=NT >$@

%.mrcx: %.alephseq refdata/iso639-2-fi.csv
	uniq $< | scripts/filter-duplicates.py | $(UCONV) -x Any-NFC | scripts/filter-fennica-repl.py | $(CATMANDU) convert MARC --type ALEPHSEQ to MARC --type XML --fix scripts/preprocess-marc.fix >$@

%-bf.rdf: %.mrcx
	java -jar $(MARC2BIBFRAMEWRAPPER) $(MARC2BIBFRAME) $^ $(URIBASEFENNICA) 2>$(patsubst %.rdf,%-log.xml,$@) | sed -e 's/<rdf:resource rdf:resource=/<bf:uri rdf:resource=/' >$@

%-schema.nt: %-bf.rdf refdata/iso639-1-2-mapping.nt refdata/ysa-skos-labels.nt
	JVM_ARGS=$(JVMARGS) $(SPARQL) --graph $< --namedGraph $(word 2,$^) --namedGraph $(word 3,$^) --query sparql/bf-to-schema.rq --out=NT | scripts/filter-bad-ntriples.py >$@ 2>$(patsubst %.nt,%.log,$@)
	
%.nt: %.rdf
	rapper $^ -q >$@

%-work-keys.nt: %-bf.rdf
	JVM_ARGS=$(JVMARGS) $(SPARQL) --data $< --query sparql/create-work-keys.rq --out=NT >$@

.SECONDEXPANSION:
refdata/%-work-keys.nt: $$(shell ls slices/$$(*)-?????.alephseq | sed -e 's/.alephseq/-work-keys.nt/')
	$(RIOT) $^ >$@

%-work-transformations.nt: %-work-keys.nt
	$(SPARQL) --data $< --query sparql/create-work-transformations.rq --out=NT >$@

slices/%-merged.nt: slices/%-schema.nt refdata/$$(shell echo $$(*)|sed -e 's/-[0-9X]\+//')-work-transformations.nt
	$(SPARQL) --data $< --data $(word 2,$^) --query sparql/merge-works.rq --out=NT >$@

merged/%-merged.nt: $$(shell ls slices/$$(*)-?????.alephseq | sed -e 's/.alephseq/-merged.nt/')
	$(RIOT) $^ >$@

%.hdt: %.nt
	$(RDF2HDT) $< $@
	# also (re)generate index, for later querying
	rm -f $@.index*
	$(HDTSEARCH) -q 0 $@

output/%.nt: merged/%-merged.hdt
	JAVA_OPTIONS=$(JVMARGS) $(HDTSPARQL) $^ "`cat sparql/consolidate-works.rq`" >$@

# Targets to be run externally

all: slice consolidate

realclean: clean
	rm -f split-input/*.alephseq split-input/*.md5
	rm -f slices/*.alephseq slices/*.md5
	rm -f refdata/*.csv refdata/*.nt

clean:
	rm -f refdata/*-work-keys.nt refdata/*-work-transformations.nt
	rm -f slices/*.mrcx
	rm -f slices/*.rdf slices/*.xml
	rm -f slices/*.nt slices/*.log
	rm -f merged/*.nt

slice: $(patsubst input/%.alephseq,slices/%.md5,$(wildcard input/*.alephseq))

mrcx: $(patsubst %.alephseq,%.mrcx,$(wildcard slices/*.alephseq))

rdf: $(patsubst %.alephseq,%-bf.rdf,$(wildcard slices/*.alephseq))

nt: $(patsubst %.alephseq,%-bf.nt,$(wildcard slices/*.alephseq))

work-keys: $(patsubst %.alephseq,%-work-keys.nt,$(wildcard slices/*.alephseq))

schema: $(patsubst %.alephseq,%-schema.nt,$(wildcard slices/*.alephseq))

merge: $(patsubst input/%.alephseq,merged/%-merged.hdt,$(wildcard input/*.alephseq))

consolidate: $(patsubst input/%.alephseq,output/%.hdt,$(wildcard input/*.alephseq))

.PHONY: all realclean clean slice mrcx rdf nt work-keys schema merge consolidate
.DEFAULT_GOAL := all

# retain all intermediate files
.SECONDARY:
