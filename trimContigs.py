# trimContigs.py
# as the name says pretty much!
# More specifically we map intron refs back to full genes and trim them down -> maybe they'll be better for phasing? who knows!
# HJ 12/02/25

# Imports
import pysam
import argparse
#import os
import pandas as pd
import numpy as np
#import matplotlib.pyplot as plt
#import seaborn as sns
#import re

from Bio import SeqIO
#from itertools import chain

if __name__ == '__main__': 
    
    # Argument setup
    
    parser = argparse.ArgumentParser(
        prog = 'trimContigs.py',
        description = 'Take a set of paftol references mapped to whole gene assembilies and trim these down to reduce overhang')      
    
    parser.add_argument('-b', '--bam', 
                        help = 'Bam file to parse')
    parser.add_argument('-r', '--ref', 
                        help = 'Ref file to trim')
    parser.add_argument('-o', '--overhang', 
                        help = 'How much overhang to keep. Default is 500',
                        default = 500)
    parser.add_argument('-O', '--output', 
                        help = 'Output dir')
    
    args = parser.parse_args()

    # Main loop

    alignment = pysam.AlignmentFile(args.bam, 'rb')
    contigs = alignment.references
    
    df = pd.DataFrame(columns = ['contig_name', 
                                 'mapped_name', 
                                 'map_start', 
                                 'map_end', 
                                 'read_length',
                                 'contig_length',
                                 'contig_span', 
                                 'relative_span',
                                 'clipping',
                                 'insertions',
                                 'flags'])

    for read in alignment:
    
        # for each read we want to:
        # find who it mapped to, does it match?
        # range of mapping  
        # issues? indels, different reference, more? 
        
        readLength = read.query_length
                
        flags = []
        clipping = 0
        insertions = 0
        
        if not read.is_unmapped and readLength >= 1:
            
            # Reads from the paftol reference are formated SPECIES-GENE
            # Split these and take anything after the '-' and convert back to a string afterwards
            readName = read.query_name
            
            # Supercontigs from our pipeline are formated SAMPLE-GENE ... do the same thing
            contigName =  alignment.get_reference_name(read.reference_id)
            
            if ('').join(readName.split('-')[-1:]) != ('').join(contigName.split('-')[-1:]) : flags.append('MN') # missmatched names flag
            
            mapStart, mapEnd = read.reference_start, read.reference_end
            span = mapEnd - mapStart
            
            # CIGAR stuff
            # Look for clipping 
            # Look for big insertions compared to the supercontigs
    
            if read.cigartuples[-1:][0][0] == 5 or read.cigartuples[-1:][0][0] == 5:
                flags.append('HC') # Hard clipping
            
            for string in read.cigartuples:
                if string[0] == 4:
                    clipping += string[1]
                if string[0] == 1:
                    insertions += string[1]
            
            if clipping: flags.append('SC') # Soft clipping
            if insertions: flags.append('ID') # Indels
            
            df.loc[len(df.index)] = [contigName, 
                                     readName, 
                                     mapStart, 
                                     mapEnd, 
                                     readLength,
                                     alignment.get_reference_length(alignment.get_reference_name(read.reference_id)),
                                     span, 
                                     span/readLength, 
                                     clipping, 
                                     insertions, 
                                     flags]
    
        else: 
            flags.append('NM') # not mapped flag
            readName = ('').join(read.query_name.split('-')[-1:])
            df.loc[len(df.index)] = ['NONE', 
                                     readName, 
                                     np.nan, 
                                     np.nan, 
                                     readLength,
                                     np.nan,
                                     np.nan, 
                                     np.nan,
                                     np.nan,
                                     np.nan,
                                     flags]
    
    fasta_file = SeqIO.parse(open(args.ref), 'fasta')
    new_file = []
    
    for seq in fasta_file:
            
        df_row = df.loc[df['contig_name'] == seq.name]
        
        try:
        
            start = max(0, int(df_row.iloc[0]['map_start'] - args.overhang))
            stop = min(int(df_row.iloc[0]['map_end'] + args.overhang), int(df_row.iloc[0]['contig_length']))
            
            new_file.append(f'>{seq.name}_trim\n{seq.seq[start:stop]}\n')
        
        except:
            
            print(f'Skipped: {seq.name}')
    
    with open(f'{args.output}/{(args.ref.split("/")[-1]).split(".")[0]}_trim.fasta', 'w') as f:
        
        f.writelines(new_file)
        
    
    df.to_csv(f'{args.output}/{(args.ref.split("/")[-1]).split(".")[0]}_stats.csv', sep = ',')