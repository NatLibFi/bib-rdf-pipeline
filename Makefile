

split-input/%: input/%.alephseq
	awk '{ print $0 > "$@-"substr($$1,0,5)".alephseq" }' <$^
