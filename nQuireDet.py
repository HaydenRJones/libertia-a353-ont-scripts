# nQuireDet.py
# HJ - 15/02/25
# v0.1
# Take output from nQuire and refrence file and split based on best phase number

from Bio import SeqIO
import pandas as pd
import argparse

if __name__ == '__main__': 
    
    parser = argparse.ArgumentParser(
        prog = 'nQuireDet.py',
        description = 'Take output from nQuire and refrence file and split based on best phase number')        
    parser.add_argument('-s', '--sample', 
                    help = 'Sample')
    args = parser.parse_args()

    df = pd.read_csv(f'./phasing/{args.sample}/nQuire_stats.tsv', sep = '\t')
    reference = SeqIO.to_dict(SeqIO.parse(f'./trim_contigs/{args.sample}/{args.sample}_contigs_trim.fasta', 'fasta'))

    ploidy = ['dip', 'tri', 'tet']

    # name, det, dLogLK
    det = []

    dip = []
    tri = []
    tet = []

    for i in range(0, len(df)):
        
        values = list((df.iloc[i])[5:8])
        idx = values.index(min(values))
        
        #this sucks, never do this!    
        name = ((df.iloc[i][0]).split('/')[-1]).split('_')[:-1]
        name = '_'.join(name)
        
        det.append([name,
                    ploidy[idx],
                    float(min(values))])
        
        eval(f'{ploidy[idx]}').append([name,
                    ploidy[idx],
                    float(min(values))])

    det_df = pd.DataFrame(det, columns = ['name', 'det', 'dLogLK'])

    dip_df = pd.DataFrame(dip, columns = ['name', 'det', 'dLogLK'])
    tri_df = pd.DataFrame(tri, columns = ['name', 'det', 'dLogLK'])
    tet_df = pd.DataFrame(tet, columns = ['name', 'det', 'dLogLK'])

    #del dip, tri, tet, det, i, idx, values, ploidy, name, df

    def split(ploidy_df, reference):
        
        temp = []
        
        for i in range(0, len(ploidy_df)):
            
            temp.append(reference[ploidy_df.iloc[i][0]])
            
        return(temp)

    SeqIO.write(split(dip_df, reference), f'./trim_contigs/{args.sample}/{args.sample}_dip.fasta', 'fasta')
    SeqIO.write(split(tri_df, reference), f'./trim_contigs/{args.sample}/{args.sample}_tri.fasta', 'fasta')
    SeqIO.write(split(tet_df, reference), f'./trim_contigs/{args.sample}/{args.sample}_tet.fasta', 'fasta')
    
    #det_df.to_csv(f'{args.sample}_nQuire_det.tsv', sep = '\t', index = False)
