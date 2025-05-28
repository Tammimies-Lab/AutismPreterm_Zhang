#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Manuscript: Prematurity and Genetic Liability for Autism Spectrum Disorder

population AF filter: remove vairants with MAX_AF > 0.001

@author: yalzha, KI
"""

import sys

vcf_filein = open(sys.argv[1],'r')
vcf_fileout = open(sys.argv[2],'w')
vcf_remove = open(sys.argv[3],'w')

# CSQ_format = "Allele|Consequence|IMPACT|SYMBOL|Gene|Feature_type|Feature|BIOTYPE|EXON|INTRON|HGVSc|HGVSp|cDNA_position|CDS_position|Protein_posi
# tion|Amino_acids|Codons|Existing_variation|DISTANCE|STRAND|FLAGS|SYMBOL_SOURCE|HGNC_ID|CCDS|ENSP|SWISSPROT|TREMBL|UNIPARC|UNIPROT_ISOFORM|REFSEQ_M
# ATCH|SOURCE|REFSEQ_OFFSET|GIVEN_REF|USED_REF|BAM_EDIT|SIFT|PolyPhen|DOMAINS|AF|AFR_AF|AMR_AF|EAS_AF|EUR_AF|SAS_AF|MAX_AF|MAX_AF_POPS|CLIN_SIG|SOMA
# TIC|PHENO|MOTIF_NAME|MOTIF_POS|HIGH_INF_POS|MOTIF_SCORE_CHANGE|TRANSCRIPTION_FACTORS"


for line in vcf_filein:
    if line.startswith('#'):
        vcf_fileout.write(line)
        
        if line.startswith('##INFO=<ID=CSQ'):
            CSQ_format=line.strip().split('Format: ')[1]
            CSQ_format = CSQ_format.split("|")
            CSQ_AF =  CSQ_format.index('MAX_AF')
        continue
    
    # get INFO column calue
    info_column = line.strip().split("\t")[7]
    info_list = info_column.split(";")
    info_dic = {}
    flag = 0
    
    for i in info_list:
        if "=" in i:
            if i.split("=")[0] == 'CSQ':
                csq = i.split("=")[1]
                csq = csq.split('|')
                af_max = csq[CSQ_AF]
                
                if af_max:
                    if float(af_max) > 0.001:
                        vcf_remove.write(line)
                    else:
                        vcf_fileout.write(line)
                else:
                    vcf_fileout.write(line)
            
vcf_filein.close()
vcf_fileout.close()  
vcf_remove.close()