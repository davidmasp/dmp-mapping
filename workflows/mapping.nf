
// helpers
include { SAMTOOLS_MERGE as SAMTOOLS_MERGE_BWA2 } from '../modules/nf-core/samtools/merge/main'
include { SAMTOOLS_MERGE as SAMTOOLS_MERGE_MINIBWA } from '../modules/nf-core/samtools/merge/main'

// genome
include { BWAMEM2_INDEX } from '../modules/nf-core/bwamem2/index/main'
include { MINIBWA_INDEX } from '../modules/nf-core/minibwa/index/main'

// aligment
include { BWAMEM2_MEM } from '../modules/nf-core/bwamem2/mem/main'
include { MINIBWA_MAP } from '../modules/nf-core/minibwa/map/main'


// needs params.bwa2index
workflow MAP {
    take:
     ch_fqs // queue: [mandatory] [ info, [fastq1, fastq2]]
     fasta // value: [mandatory] [ .fa file]
     fai // value: [optional] [ .fai file]
     gzi // value: [optional] [ .gzi file]
    main:

    metrics = Channel.empty()
    versions = Channel.empty()
    mapped_bams = Channel.empty()

    if (!params.skip_bwa2) {
        if (params.bwa2index) {
            println("bwa index provided, skipping indexing")
            bwa_index = [[:], file(params.bwa2index)]
        } else {
            println("bwa index NOT provided, creating...")
            BWAMEM2_INDEX([[:], fasta])
            bwa_index = BWAMEM2_INDEX.out.index
            versions = versions.mix(BWAMEM2_INDEX.out.versions_bwamem2)
        }

        BWAMEM2_MEM(ch_fqs, bwa_index, [[:], fasta], true)
        grouped_bwa2_bam = BWAMEM2_MEM.out.bam \
            | map { meta, bam ->
                meta = meta.subMap(meta.keySet() - 'lane')
                tuple(meta, bam, [])
            }
            | groupTuple(by: 0) \
            | map { meta, bam, index -> tuple(meta, bam, index.flatten()) }

        SAMTOOLS_MERGE_BWA2(grouped_bwa2_bam, [[:], fasta, fai, gzi])
        bwa2_bams = SAMTOOLS_MERGE_BWA2.out.bam \
            | map { meta, bam -> tuple(meta + [maptype: 'bwa-mem2'], bam) }
        mapped_bams = mapped_bams.mix(bwa2_bams)

        versions = versions.mix(BWAMEM2_MEM.out.versions_bwamem2)
        versions = versions.mix(BWAMEM2_MEM.out.versions_samtools)
        versions = versions.mix(SAMTOOLS_MERGE_BWA2.out.versions_samtools)
    }

    if (!params.skip_minibwa) {
        if (params.minibwaindex) {
            println("minibwa index provided, skipping indexing")
            minibwa_index = [[:], file(params.minibwaindex)]
        } else {
            println("minibwa index NOT provided, creating...")
            MINIBWA_INDEX([[:], fasta])
            minibwa_index = MINIBWA_INDEX.out.index
            versions = versions.mix(MINIBWA_INDEX.out.versions_minibwa)
        }

        MINIBWA_MAP(ch_fqs, minibwa_index, [[:], fasta], true)
        grouped_minibwa_bam = MINIBWA_MAP.out.aligned \
            | map { meta, bam ->
                meta = meta.subMap(meta.keySet() - 'lane')
                tuple(meta, bam, [])
            }
            | groupTuple(by: 0) \
            | map { meta, bam, index -> tuple(meta, bam, index.flatten()) }

        SAMTOOLS_MERGE_MINIBWA(grouped_minibwa_bam, [[:], fasta, fai, gzi])
        minibwa_bams = SAMTOOLS_MERGE_MINIBWA.out.bam \
            | map { meta, bam -> tuple(meta + [maptype: 'minibwa'], bam) }
        mapped_bams = mapped_bams.mix(minibwa_bams)

        versions = versions.mix(MINIBWA_MAP.out.versions_minibwa)
        versions = versions.mix(MINIBWA_MAP.out.versions_samtools)
        versions = versions.mix(SAMTOOLS_MERGE_MINIBWA.out.versions_samtools)
    }

    if (params.skip_bwa2 && params.skip_minibwa) {
        error("At least one mapper must be enabled. Set --skip_bwa2 false or --skip_minibwa false.")
    }


    emit:
     mapped = mapped_bams
     versions
     metrics
}
