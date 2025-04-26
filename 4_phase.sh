#bin/bash

echo "=============="
echo "sample	: $1"
echo "phase	: $2"
echo "=============="
	
minimap2 -ax map-ont ./trim_contigs/$1/$1\_contigs_trim.fasta ./data/long_reads/$1\_chop.fastq | samtools view -b -F 4 | samtools sort -o ./phasing/$1/$1.bam --write-index -

samtools faidx ./trim_contigs/$1/$1\_contigs_trim.fasta

freebayes-parallel <(fasta_generate_regions.py ./trim_contigs/$1/$1\_contigs_trim.fasta.fai 10000) 8 \ -f ./trim_contigs/$1/$1\_contigs_trim.fasta -p $2 ./phasing/$1/$1.bam --min-mapping-quality 50 --min-base-quality 20 --min-alternate-fraction 0.2 > ./phasing/$1/$1.vcf

whatshap polyphase ./phasing/$1/$1.vcf ./phasing/$1/$1.bam --ploidy $2 -o ./phasing/$1/$1\_wh.vcf -t 8 --ignore-read-groups -t 8 --mapping-quality 50
bgzip ./phasing/$1\/$1\_wh.vcf
tabix -p vcf ./phasing/$1\/$1\_wh.vcf.gz
whatshap haplotag -o ./phasing/$1/$1\_tag.bam ./phasing/$1\/$1\_wh.vcf.gz ./phasing/$1/$1.bam --ignore-read-groups --no-reference --ploidy $2 --output-haplotag-list ./phasing/$1\/$1\_wh.tsv
samtools index ./phasing/$1/$1\_tag.bam


#samtools merge -o ./phasing/$1/$1\_tag.bam ./phasing/$1/$1\_tag_dip.bam ./phasing/$1/$1\_tag_tri.bam ./phasing/$1/$1\_tag_tet.bam
#samtools index ./phasing/$1/$1\_tag.bam

#awk 'FNR==1 && NR!=1{next;}{print}' *wh_*.tsv > $1\_tag.tsv
#whatshap split -o $DIR/$1\_H1.bam -o $DIR/$1\_H2.bam -o $DIR/$1\_H3.bam -o $DIR/$1\_H4.bam $1\_tag.bam $1\_tag.tsv
#for x in 1 2 3 4; do
#	samtools index $DIR/$1\_H$x.bam
#done;
