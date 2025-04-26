
// helpers
include { SAMTOOLS_MERGE } from '../modules/nf-core/samtools/merge/main'  

// genome
include { BWAMEM2_INDEX } from '../modules/nf-core/bwamem2/index/main' 

// aligment
include { BWAMEM2_MEM } from '../modules/nf-core/bwamem2/mem/main' 
include { GATK4_MARKDUPLICATES } from '../modules/nf-core/gatk4/markduplicates/main'

// needs params.bwaindex
workflow MAP {
    take:
     ch_fqs // queue: [mandatory] [ info, [fastq1, fastq2]]
     fasta // value: [mandatory] [ .fa file]
     fai // value: [optional] [ .fai file]
    main:

    metrics = Channel.empty()
    versions = Channel.empty()

    if (params.bwaindex) {
        println("bwa index provided, skipping indexing")
        bwa_index = [[:], file(params.bwaindex)]
    } else {
        println("bwa index NOT provided, creating...")
        BWAMEM2_INDEX([[:], fasta])
        bwa_index = BWAMEM2_INDEX.out.index
    }

    BWAMEM2_MEM(ch_fqs, bwa_index,[[:], fasta], true)
    // we SHOULD MERGE HERE!
    grouped_bam = BWAMEM2_MEM.out.bam \
        | map {meta, bam -> 
            meta.remove('lane')
            tuple(meta, bam)
        } 
        | groupTuple(by: 0)

    SAMTOOLS_MERGE(grouped_bam, [[:], []], [[:], []])
    GATK4_MARKDUPLICATES(SAMTOOLS_MERGE.out.bam, fasta, fai)

    metrics = metrics.mix(GATK4_MARKDUPLICATES.out.metrics)
    versions = versions.mix(GATK4_MARKDUPLICATES.out.versions)
    versions = versions.mix(BWAMEM2_MEM.out.versions)

    emit:
     versions
     metrics
}
