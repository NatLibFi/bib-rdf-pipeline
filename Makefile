

# Pattern rules used internally

split-input/%.md5: input/%.alephseq
	awk '{ print $0 > "$(patsubst %.md5,%,$@)-"substr($$1,0,5)".alephseq" }' <$^
	md5sum $(patsubst %.md5,%,$@)-*.alephseq >$@

%.md5: %
	md5sum $^ >$@


# Targets to be run externally

clean:
	rm split-input/*.alephseq

split: $(patsubst input/%.alephseq,split-input/%.md5,$(wildcard input/*.alephseq))
	
	


.PHONY: clean split

