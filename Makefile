# Paths to non-unix-standard tools that we depend on; can be overridden on the command line

CATMANDU=catmandu
MARC2BIBFRAME2=$(PATH_PREFIX)../marc2bibframe2
XSLTPROC=xsltproc
RSPARQL=rsparql
RIOT=riot
SPARQL=sparql
UCONV=uconv
RDF2HDT=rdf2hdt
HDTSEARCH=hdtSearch
HDTSPARQL=hdtsparql.sh

# Other configuration settings
FINTOSPARQL=http://api.dev.finto.fi/sparql
URIBASEFENNICA=http://urn.fi/URN:NBN:fi:bib:me:
JVMARGS="-Xmx4G"

# Pattern rules used internally

split-input/%.md5: input/%.alephseq
	scripts/split-input.sh $(patsubst %.md5,%,$@) <$^
	cd split-input; md5sum $(patsubst split-input/%.md5,%,$@)-*-in.alephseq >`basename $@`

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

refdata/cn-labels.nt: sparql/extract-cn-labels.rq
	$(RSPARQL) --service $(FINTOSPARQL) --query $^ --results=NT >$@

refdata/RDACarrierType.nt:
	curl -s http://rdaregistry.info/termList/RDACarrierType.nt >$@

refdata/RDAContentType.nt:
	curl -s http://rdaregistry.info/termList/RDAContentType.nt | sed -e 's|RDAContentType//|RDAContentType/|g' >$@

refdata/RDAMediaType.nt:
	curl -s http://rdaregistry.info/termList/RDAMediaType.nt >$@

%-preprocessed.alephseq: %-in.alephseq
	uniq $< | scripts/filter-duplicates.py | $(UCONV) -x Any-NFC -i | scripts/filter-fennica-repl.py >$@

%.mrcx: %-preprocessed.alephseq refdata/iso639-2-fi.csv
	$(CATMANDU) convert MARC --type ALEPHSEQ to MARC --type XML --fix scripts/filter-marc.fix --fix scripts/strip-personal-info.fix --fix scripts/preprocess-marc.fix <$< >$@

%-bf2.rdf: %.mrcx
	$(XSLTPROC) --stringparam baseuri $(URIBASEFENNICA) $(MARC2BIBFRAME2)/xsl/marc2bibframe2.xsl $^ >$@

%.nt: %.rdf
	$(RIOT) -q $^ >$@

%-rewritten.nt: %-bf2.nt
	scripts/rewrite-uris.py $^ | scripts/filter-bad-ntriples.py >$@ 2>$(patsubst %.nt,%.log,$@)

%-schema.nt: %-rewritten.nt
	JVM_ARGS=$(JVMARGS) $(SPARQL) --graph $< --query sparql/bf-to-schema.rq --out=NT >$@ 

%-reconciled.nt: %-schema.nt refdata/iso639-1-2-mapping.nt refdata/ysa-skos-labels.nt refdata/RDACarrierType.nt refdata/RDAContentType.nt refdata/RDAMediaType.nt refdata/cn-labels.nt
	JVM_ARGS=$(JVMARGS) $(SPARQL) --graph $< --namedGraph $(word 2,$^) --namedGraph $(word 3,$^) --namedGraph $(word 4,$^) --namedGraph $(word 5,$^) --namedGraph $(word 6,$^) --namedGraph $(word 7,$^) --query sparql/reconcile.rq --out=NT >$@
	
%-work-keys.nt: %-rewritten.nt
	JVM_ARGS=$(JVMARGS) $(SPARQL) --data $< --query sparql/create-work-keys.rq --out=NT >$@

.SECONDEXPANSION:
refdata/%-work-keys.nt: $$(shell ls slices/$$(*)-?????-in.alephseq | sed -e 's/-in.alephseq/-work-keys.nt/')
	$(RIOT) $^ >$@

refdata/%-agent-keys.nt: $$(shell ls slices/$$(*)-?????-in.alephseq | sed -e 's/-in.alephseq/-agent-keys.nt/')
	$(RIOT) $^ >$@

%-transformations.nt: %-keys.nt
	scripts/create-merge-transformations.py <$^ >$@

slices/%-merged.nt: slices/%-reconciled.nt refdata/$$(shell echo $$(*)|sed -e 's/-[0-9X]\+//')-work-transformations.nt
	$(SPARQL) --data $< --data $(word 2,$^) --query sparql/merge.rq --out=NT >$@

slices/%-agent-keys.nt: slices/%-merged.nt
	JVM_ARGS=$(JVMARGS) $(SPARQL) --data $< --query sparql/create-agent-keys.rq --out=NT >$@

slices/%-merged2.nt: slices/%-merged.nt refdata/$$(shell echo $$(*)|sed -e 's/-[0-9X]\+//')-agent-transformations.nt
	$(SPARQL) --data $< --data $(word 2,$^) --query sparql/merge.rq --out=NT >$@

merged/%.mrcx: $$(shell ls slices/$$(*)-?????-in.alephseq | sed -e 's/-in.alephseq/-preprocessed.alephseq/')
	cat $^ | $(CATMANDU) convert MARC --type ALEPHSEQ to MARC --type XML --pretty 1 --fix scripts/filter-marc.fix --fix scripts/strip-personal-info.fix >$@

merged/%-merged.nt: $$(shell ls slices/$$(*)-?????-in.alephseq | sed -e 's/-in.alephseq/-merged2.nt/') refdata/fennica-collection.ttl
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
	rm -f slices/*-preprocessed.alephseq
	rm -f slices/*.mrcx
	rm -f slices/*.rdf
	rm -f slices/*.nt slices/*.log
	rm -f merged/*.nt merged/*.mrcx

slice: $(patsubst input/%.alephseq,slices/%.md5,$(wildcard input/*.alephseq))

preprocess: $(patsubst %-in.alephseq,%-preprocessed.alephseq,$(wildcard slices/*-in.alephseq))

marcdist: $(patsubst input/%.alephseq,merged/%.mrcx,$(wildcard input/*.alephseq))

mrcx: $(patsubst %-in.alephseq,%.mrcx,$(wildcard slices/*-in.alephseq))

rdf: $(patsubst %-in.alephseq,%-bf2.rdf,$(wildcard slices/*-in.alephseq))

rewrite: $(patsubst %-in.alephseq,%-rewritten.nt,$(wildcard slices/*-in.alephseq))

work-keys: $(patsubst %-in.alephseq,%-work-keys.nt,$(wildcard slices/*-in.alephseq))

work-transformations: $(patsubst input/%.alephseq,refdata/%-work-transformations.nt,$(wildcard input/*.alephseq))

schema: $(patsubst %-in.alephseq,%-schema.nt,$(wildcard slices/*-in.alephseq))

reconcile: $(patsubst %-in.alephseq,%-reconciled.nt,$(wildcard slices/*-in.alephseq))

agent-keys: $(patsubst %-in.alephseq,%-agent-keys.nt,$(wildcard slices/*-in.alephseq))

agent-transformations: $(patsubst input/%.alephseq,refdata/%-agent-transformations.nt,$(wildcard input/*.alephseq))

merge: $(patsubst input/%.alephseq,merged/%-merged.nt,$(wildcard input/*.alephseq))

consolidate: $(patsubst input/%.alephseq,output/%.nt,$(wildcard input/*.alephseq))

.PHONY: all realclean clean slice preprocess mrcx rdf rewrite work-keys schema merge consolidate
.DEFAULT_GOAL := all

# retain all intermediate files
.SECONDARY:
