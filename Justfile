
set dotenv-load
set dotenv-required

genome := '/processing_data/reference_datasets/iGenomes/2023.1/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa'
fai := '/processing_data/reference_datasets/iGenomes/2023.1/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa.fai'

outfile := '/group/sottoriva/david.mas/sandbox/20250427_matchednormalsforont'


run:
    nextflow run main.nf --fqindex index.csv --genome {{ genome }} --fai {{ fai }} --outdir {{ outfile }} -resume -profile slurm,hpc,conda,tower -w /scratch/david.mas/nxf_mapping



test_reference := "/Volumes/Gumpert/FILES/research_data/gatk_resources/large/Homo_sapiens_assembly38.fasta"


# Subset chr19, chr20 and chr21 from the full hg38 reference to create a mini FASTA for testing.
test-ref outdir='test_data':
    mkdir -p '{{ outdir }}'
    samtools faidx '{{ test_reference }}' chr19 chr20 chr21 > '{{ outdir }}/mini_hg38.fa'
    samtools faidx '{{ outdir }}/mini_hg38.fa'


# Generate paired test FASTQ files from a FASTA with wgsim.
test-fq fasta='test_data/mini_hg38.fa' outdir='test_data/wgsim' prefix='test' pairs='1000000':
    mkdir -p '{{ outdir }}'
    wgsim -N {{ pairs }} -1 150 -2 150 -e 0.01 -r 0.00001 '{{ fasta }}' '{{ outdir }}/{{ prefix }}_1.fq' '{{ outdir }}/{{ prefix }}_2.fq'
    gzip -f '{{ outdir }}/{{ prefix }}_1.fq' '{{ outdir }}/{{ prefix }}_2.fq'


# Run the full pipeline locally with test data (wgsim FASTQs + mini_hg38 reference).
test-run outdir='test_data/results':
    nextflow run main.nf \
        --fqindex test_data/test_index.csv \
        --genome test_data/mini_hg38.fa \
        --fai test_data/mini_hg38.fa.fai \
        --outdir {{ outdir }} \
        -profile local,micromamba \
        -resume
