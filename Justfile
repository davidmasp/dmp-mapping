
set dotenv-load
set dotenv-required

genome := '/processing_data/reference_datasets/iGenomes/2023.1/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa' 
fai := '/processing_data/reference_datasets/iGenomes/2023.1/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa.fai' 

outfile := '/group/sottoriva/david.mas/sandbox/20250427_matchednormalsforont'

run:
    nextflow run main.nf --fqindex miniindex.csv --genome {{genome}} --fai {{fai}} --outdir {{outfile}} -resume -profile slurm,hpc,conda,tower -w /scratch/david.mas/nxf_mapping

