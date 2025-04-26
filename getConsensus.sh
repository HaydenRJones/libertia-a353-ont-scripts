#bin/bash

echo "contig   : $1"

mkdir loci_alignments/loci/$1

for sample in ./loci_alignments/samples/*/; do
	
	for file in $sample*.bam; do
		
		fileName=$(basename "$file" .bam) 									# files are DIR/SAMPLE_HAPLOTYPE.BAM extract just the SAMPLE_HAPLOTYPE
		refName=$(samtools idxstats $file | head -n 1 | cut -d'_' -f1)		# the ref is formated as SAMPLE-Libertia_LOCI_trim. We don't always know what sample the ref came from so we extract it using samtools idxstats
		
		samtools consensus --mode simple --ambig --call-fract 0.40 $file -r $refName\_Libertia-$1\_trim -o ./loci_alignments/$fileName\_$1.fasta
		
	done;

done;

for file in loci_alignments/*_$1\.fasta; do

   echo ">$file" >> loci_alignments/temp.fasta
   tail -n +2 $file >> loci_alignments/temp.fasta
   echo >> loci_alignments/temp.fasta

done;

awk 'BEGIN {RS = ">" ; FS = "\n" ; ORS = ""} {if ($2) print ">"$0}' loci_alignments/temp.fasta > loci_alignments/temp2.fasta

mafft --localpair --adjustdirection --maxiterate 100 --thread 8 loci_alignments/temp2.fasta > loci_alignments/loci/$1/$1\_align.fasta
sed -i 's/_R_//g' loci_alignments/loci/$1/$1\_align.fasta
sed -i 's/loci_alignments\///g' loci_alignments/loci/$1/$1\_align.fasta
sed -i 's/\.fasta//g' loci_alignments/loci/$1/$1\_align.fasta

rm -rf loci_alignments/*_$1.fasta
rm -rf loci_alignments/temp*.fasta

#CIAlign --infile loci_alignments/loci/$1/$1\_align.fasta --outfile_stem loci_alignments/loci/$1/$1\_CI --remove_divergent --remove_divergent_minperc 0.5 --crop_ends --crop_ends_mingap_perc 0.10 --crop_divergent
#clipkit -m kpic-gappy --gaps 0.1 -gc NnXx-? loci_alignments/loci/$1/$1\_CI_cleaned.fasta -o loci_alignments/loci/$1/$1\_clean.fasta