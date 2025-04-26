#!/bin/bash

echo "Sample   : $1"
echo "Ref file : $2"

mkdir trim_contigs trim_contigs/$1

minimap2 -ax splice flye_assembly/$1\_contigs_merge.fasta $2 | samtools sort -o trim_contigs/$1/$1\_paftol.bam --write-index -

python trimContigs.py -b trim_Contigs/$1/$1\_paftol.bam -r references/$1\_contigs.fasta -O trim_contigs/$1