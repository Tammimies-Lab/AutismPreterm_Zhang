# Variant filter

## DNV filtering ----------

### Slivar
pslivar expr --vcf in.vcf.gz --ped SPARK_trio.ped --js slivar-functions.js --trio "denovo:denovo(kid, mom, dad)" --fasta GRCh38_full_analysis_set_plus_decoy_hla.fa --pass-only --processes 16 | bgzip -c -@ 16 > slivar.pass.vcf.gz

### GATK - retain variants with 
gatk VariantAnnotator -A PossibleDeNovo -R GRCh38_full_analysis_set_plus_decoy_hla.fa --pedigree SPARK_trio.ped -V slivar.pass.vcf.gz -O slivar.gatk.pass.vcf.gz

### filter
bcftools view --threads 16 -e "INFO/hiConfDeNovo=''" slivar.gatk.pass.vcf.gz -Oz -o DNV.vcf.gz

## Inherited variant filtering ----------

pslivar expr --vcf in.vcf.gz --ped SPARK_trio.ped --js slivar-functions.js --trio "inheritVar:inherited_var(kid, mom, dad)" --fasta GRCh38_full_analysis_set_plus_decoy_hla.fa --pass-only --processes 16 | bgzip -c -@ 16 > pass.vcf.gz

## More quality control ----------

### annotation
vep --cache --dir_cache $VEP_CACHE --fork 16 --offline -i in.vcf.gz --assembly GRCh38 --force_overwrite --symbol --merged --sift b --polyphen b --max_af --af_1kg --fasta GRCh38_full_analysis_set_plus_decoy_hla.fa --plugin CADD,whole_genome_SNVs.tsv.gz,gnomad.genomes.r3.0.indel.tsv.gz --vcf -o STDOUT | bgzip -c -@ 16 > out.vcf.gz

snpEff GRCh38.105 vcfin.gz | bgzip -c -@ 16 > out.vcf.gz

table_annovar.pl -vcfinput in.vcf humandb -buildver hg38 -out anno -remove -protocol revel,ljb26_all  -operation f,f

### AF filter - remove DNV>0.001, inderit
bcftools filter -e 'INFO/AF > 0.001' in.vcf.gz -Oz -o out.vcf.gz
python AF_max_filter.py in.vcf pass.vcf fail.vcf

### remove long AT
zcat in.vcf.gz  | grep '#' > out.vcf
zcat in.vcf.gz | grep -v '#' | awk -F'\t' '$5 !~ /AAAAAAAAAA|TTTTTTTTTT/' >> out.vcf

### clean regions
bedtools intersect -v -a in.vcf -b hg38_centromeres_231124.bed LCR-hs38.bed > out.vcf


