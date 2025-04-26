#!/bin/bash

echo "Sample Name : $1"
echo "Data file   : $2"
echo "Ref file    : $3"

echo "\n===== Alignment =====\n"

mkdir $1 $1/assembly
minimap2 -ax map-ont $3 $2 | samtools sort -o $1\/$1\_prelim.bam --write-index -

echo "\n===== Assembly =====\n"

seqlist=$(grep '^>' "$3" | sed 's/^>//')

for seq in $seqlist; do

	mkdir $1\/assembly/$seq

	samtools view -b -F 4 $1\/$1\_prelim.bam $seq | samtools fastq > $1/assembly/$seq\/$seq\.fastq
	flye --nano-hq $1/assembly/$seq\/$seq\.fastq -t 8 --iterations 3 -o $1/assembly/$seq\/flye

done;
