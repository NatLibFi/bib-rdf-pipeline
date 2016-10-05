

# Pattern rules used internally

split-input/%.md5: input/%.alephseq
	awk '{ print $0 > "$(patsubst %.md5,%,$@)-"substr($$1,0,5)".alephseq" }' <$^
	cd split-input; md5sum $(patsubst split-input/%.md5,%,$@)-*.alephseq >`basename $@`

%.md5: %
	md5sum $^ >$@

slices/%.md5: split-input/%.md5
	scripts/update-slices.sh $^ $@

# Targets to be run externally

clean:
	rm -f split-input/*.alephseq split-input/*.md5
	rm -f slices/*.alephseq slices/*.md5

slice: $(patsubst input/%.alephseq,slices/%.md5,$(wildcard input/*.alephseq))

.PHONY: clean slice
