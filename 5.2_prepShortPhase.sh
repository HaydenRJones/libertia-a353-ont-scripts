#bin/bash

echo "=============="
echo "samples	: $1"
echo "ref	: $2"
echo "phase	: $3"
echo "=============="

#awk 'FNR==1 && NR!=1{next;}{print}' ./short_reads/$1/*wh_*.tsv > ./short_reads/$1/$1\_tag.tsv

mkdir loci_alignments/samples/$1

if [ "$3" -eq 3 ]; then
	
	whatshap split -o ./loci_alignments/samples/$1/$1\_H1.bam -o ./loci_alignments/samples/$1/$1\_H2.bam -o ./loci_alignments/samples/$1/$1\_H3.bam ./short_reads/$1/$1\_tag_$1.bam ./short_reads/$1/$1\_wh_$1.tsv
	
	for x in 1 2 3; do

	samtools index ./loci_alignments/samples/$1/$1\_H$x.bam
	
	done;

elif [ "$3" -eq 2 ]; then
	
	whatshap split -o ./loci_alignments/samples/$1/$1\_H1.bam -o ./loci_alignments/samples/$1/$1\_H2.bam ./short_reads/$1/$1\_tag_$1.bam ./short_reads/$1/$1\_wh_$1.tsv
	
	for x in 1 2; do

	samtools index ./loci_alignments/samples/$1/$1\_H$x.bam
	
	done;
	
elif [ "$3" -eq 1 ]; then
	
	cp ./short_reads/$1/$1\_ref_$2.bam loci_alignments/samples/$1/$1.bam
	
	samtools index loci_alignments/samples/$1/$1.bam

else

echo "SKIPPED $1"

fi


