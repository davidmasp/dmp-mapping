
// post-mapping
include { PICARD_MARKDUPLICATES } from '../modules/nf-core/picard/markduplicates/main'
include { MOSDEPTH } from '../modules/nf-core/mosdepth/main'
include { SAMTOOLS_INDEX } from '../modules/nf-core/samtools/index/main'

workflow POSTMAPPING {
    take:
     ch_mapped // queue: [mandatory] [ meta, bam ] with meta.maptype
     fasta // value: [mandatory] [ .fa file]
     fai // value: [optional] [ .fai file]

    main:
    metrics = Channel.empty()
    versions = Channel.empty()

    PICARD_MARKDUPLICATES(ch_mapped, [[:], fasta, fai])
    SAMTOOLS_INDEX(PICARD_MARKDUPLICATES.out.bam)
    bambai_ch = PICARD_MARKDUPLICATES.out.bam \
        | combine(SAMTOOLS_INDEX.out.index, by: 0) \
        | map {meta, bam, bai ->
            tuple(meta, bam, bai, [])
        }
    MOSDEPTH(bambai_ch, [[], []], [])

    metrics = metrics.mix(PICARD_MARKDUPLICATES.out.metrics)
    versions = versions.mix(PICARD_MARKDUPLICATES.out.versions_picard)
    versions = versions.mix(SAMTOOLS_INDEX.out.versions_samtools)
    versions = versions.mix(MOSDEPTH.out.versions_mosdepth)
    versions = versions.mix(MOSDEPTH.out.versions_gzip)

    emit:
     versions
     metrics
}
