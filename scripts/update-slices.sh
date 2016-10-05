#!/bin/bash

srcmd5file=$1
srcdir=`dirname $srcmd5file`
dstmd5file=$2
dstdir=`dirname $dstmd5file`

function copy_file {
	echo "copying $1 to $dstdir"
	cp $srcdir/$1 $dstdir
}

# Copy the files which are new or have changed
while read -r srcsum file
do
	echo "$file: $md5"
	if [ -f $dstdir/$file ]; then
		echo "file $file found in $dstdir"
		if [ -f $dstmd5file ] ; then
			dstsum=`grep -F "$file" $dstmd5file | cut -c1-32`
			if [ "$srcsum" != "$dstsum" ]; then
				echo "$srcsum $dstsum - sums differ"
				copy_file $file
			else
				echo "$srcsum $dstsum - sums are same"
			fi
		else
			"destination md5file $dstmd5file not found"
		fi
	else
		echo "file $file not found in $dstdir"
		copy_file $file
	fi
done < $srcmd5file

# TODO: purge files from dstdir that don't exist in srcdir

# Copy the md5sum file
cp $srcmd5file $dstmd5file
