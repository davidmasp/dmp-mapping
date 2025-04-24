
set dotenv-load
set dotenv-required

genome := '/processing_data/reference_datasets/iGenomes/2023.1/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa' 
fai := '/processing_data/reference_datasets/iGenomes/2023.1/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa.fai' 
# bwaindex := '/processing_data/reference_datasets/iGenomes/2023.1/Homo_sapiens/UCSC/hg38/Sequence/BWAIndex'

run:
    nextflow run main.nf --index index.csv --genome {{genome}} --fai {{fai}} -resume -profile slurm,hpc,conda,tower -w /scratch/david.mas/nxf_mapping


