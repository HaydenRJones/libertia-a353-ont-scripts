#bin/bash

echo "ref   : $1"

reflist=$(grep '^>' "$1" | sed 's/^>L..[0-9]_Libertia-//' | sed 's/_trim//')

for ref in $reflist; do
	
	#CIAlign --infile loci_alignments/loci/$ref/$ref\_align.fasta --outfile_stem loci_alignments/loci/$ref/$ref\_CI --remove_divergent --remove_divergent_minperc 0.75 --crop_ends --crop_ends_mingap_perc 0.10 --crop_divergent
	#clipkit -m kpic-gappy --gaps 0.1 -gc NnXx-? loci_alignments/loci/$ref/$ref\_CI_cleaned.fasta -o loci_alignments/loci/$ref/$ref\_clean.fasta
	
	clipkit -m kpic-gappy --gaps 0.1 -gc NnXx-? loci_alignments/loci/$ref/$ref\_align.fasta -o loci_alignments/loci/$ref/$ref\_clean.fasta
	fasttree -nt loci_alignments/loci/$ref/$ref\_clean.fasta > loci_alignments/loci/$ref/$ref\_clean.tree
	
	#fasttree -nt loci_alignments/loci/$ref/$ref\_align.fasta > loci_alignments/loci/$ref/$ref\_align.tree
	#iqtree2 -s loci_alignments/loci/$ref/$ref\_clean.fasta -nt AUTO -mem 20G
	#raxml-ng --all --msa loci_alignments/loci/$ref/$ref\_ck.fasta --model GTR+G
	
	#Rscript makeTree.R $ref
	#figtree.sh -graphic JPEG -width 750 -height 750 loci_alignments/loci/$ref/$ref\_clean.fasta.raxml.bestTree loci_alignments/loci/$ref/$ref\.png

done; 
