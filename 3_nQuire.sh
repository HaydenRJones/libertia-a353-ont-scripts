#bin/bash

echo "=============="
echo "sample	: $1"
echo "ref	: $2"
echo "=============="

seqList=`grep '^>' $2 | tr -d '>'` 

mkdir phasing/$1 
mkdir phasing/$1/nQuire
mkdir phasing/$1/nQuire/bin 
mkdir phasing/$1/nQuire/bam

minimap2 -ax map-ont trim_contigs/$1/$1\_contigs_trim.fasta data/long_reads/$1\_chop.fastq | samtools sort -o phasing/$1/$1\_contigs_trim.bam --write-index -

for seq in $seqList; do
	
	samtools view -b -F 4 phasing/$1/$1\_contigs_trim.bam $seq > phasing/$1/nQuire/bam/$1\_$seq\.bam
	
	nQuire create -b phasing/$1/nQuire/bam/$1\_$seq\.bam -o phasing/$1\/nQuire/bin/$seq
	nQuire denoise -o phasing/$1/nQuire/bin/$seq\_denoised phasing/$1/nQuire/bin/$seq\.bin 
	
done

nQuire lrdmodel -t 8 phasing/$1/nQuire/bin/*_denoised.bin >  phasing/$1/nQuire_stats.tsv

python nQuireDet.py -s $1