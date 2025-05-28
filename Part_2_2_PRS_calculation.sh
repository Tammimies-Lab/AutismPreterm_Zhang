# PRS calculation

python PRScs.py --ref_dir=/PRScs/ldblk_1kg_eur --bim_prefix=filein --sst_file=iPSYCH-PGC_ASD_Nov2017 --n_gwas=46351 --phi=1e-2 --out_dir=/Output/

plink --bfile filein --allow-extra-chr --score pst_eff_a1_b0.5_phi1e-02_chrALL.txt 2 4 6 --out fileout
