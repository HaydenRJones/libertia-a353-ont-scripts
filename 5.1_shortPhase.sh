#bin/bash

echo "=============="
echo "sample	: $1"
echo "ref	: $2"
echo "phase	: $3"
echo "=============="

mkdir short_reads/$1/

if [ "$3" ]
	then
		
		# Initally map against a long read gene reference, and haplotag using the long read SNPs from the same sample
		
		minimap2 -ax sr ./trim_contigs/$2/$2\_contigs_trim.fasta ./data/short_reads/$1/*.fastq.gz | samtools view -b -F 4 | samtools sort -o ./short_reads/$1/$1\_ref_$2\_$3.bam --write-index -
		#whatshap haplotag -o ./short_reads/$1/$1\_tag_ref_$2.bam ./phasing/$2/$2\_wh.vcf.gz ./short_reads/$1/$1\_ref_$2\_$3.bam --ignore-read-groups --reference trim_contigs/$2/$2\_contigs_trim.fasta --ploidy $3 --output-haplotag-list ./short_reads/$1\/$1\_wh.tsv		
		#samtools index ./short_reads/$1/$1\_tag_ref_$2.bam
		
		# Then call SNPs in the mapping from the short read data, phase these SNPs using the long read mapping, and then haplotag the original short read mapping
		
		freebayes-parallel <(fasta_generate_regions.py ./trim_contigs/$2/$2\_contigs_trim.fasta.fai 10000) 8 \ -f ./trim_contigs/$2/$2\_contigs_trim.fasta -p $3 ./short_reads/$1/$1\_ref_$2\_$3.bam --min-mapping-quality 50 --min-base-quality 20 --min-alternate-fraction 0.2 > ./short_reads/$1\/$1.vcf
		
		whatshap polyphase ./short_reads/$1\/$1.vcf ./phasing/$2/$2.bam --ploidy $3 -o ./short_reads/$1/$1\_wh_$2.vcf --ignore-read-groups -t 8 --mapping-quality 50

		bgzip ./short_reads/$1/$1\_wh_$2.vcf
		tabix -p vcf ./short_reads/$1/$1\_wh_$2.vcf.gz
		whatshap haplotag -o ./short_reads/$1/$1\_tag_$1.bam ./short_reads/$1/$1\_wh_$2.vcf.gz ./short_reads/$1/$1\_ref_$2\_$3.bam --ignore-read-groups --no-reference --ploidy $3 --output-haplotag-list ./short_reads/$1\/$1\_wh_$1.tsv
		samtools index ./short_reads/$1/$1\_tag_$1.bam 

else
	
	echo "Phasing not specificed!"
	echo "Mapping reads to reference and not calling phase"
	
	minimap2 -ax sr ./trim_contigs/$2/$2\_contigs_trim.fasta ./data/short_reads/$1/*.fastq.gz | samtools view -b -F 4 | samtools sort -o ./short_reads/$1/$1\_ref_$2.bam --write-index -

fi
