#bin/bash

echo "ref   : $1"

reflist=$(grep '^>' "$1" | sed 's/^>L..[0-9]_Libertia-//' | sed 's/_trim//')

mkdir loci_alignments/loci

for ref in $reflist; do
	
	#echo $ref
	./loci_alignments/getConsensus.sh $ref

done;