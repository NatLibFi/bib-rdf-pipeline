#!/bin/bash

# Split a sparse Aleph dump given on stdin into batches of max 10000 records

outputbase=$1

# 0. Remove batches from previous run

rm -f $outputbase-?????-in.alephseq

# 1. Split based on sequence numbers into batches of at most 10000 records

awk -v base="$outputbase" '{ print $0 > base "-" substr($1,0,5) "-in.alephseq" }'

# 2. Check whether it is possible to merge consecutive small files
# into larger batches that are still less than 10000 records

bundles=`ls $outputbase-?????-in.alephseq|sed -e 's/.-in.alephseq$//'|sort|uniq`
for b in $bundles; do
	files=`ls $b*|wc -l`
	if [ $files -gt 1 ]; then
		# more than one file so merging may be possible
		count=`cat $b*|cut -c1-10|uniq|wc -l`
		if [ $count -lt 10000 ]; then
			# total less than 10000 records - we can merge
			cat $b?-in.alephseq >${b}-in.alephseq
			rm $b?-in.alephseq
			mv ${b}-in.alephseq ${b}X-in.alephseq
		fi
	fi
done
