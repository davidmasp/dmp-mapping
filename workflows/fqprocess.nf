
// fqs
include { FASTQC } from '../modules/nf-core/fastqc' 
include { FASTQC as FASTQC1} from '../modules/nf-core/fastqc' 
include { FASTQC as FASTQC2} from '../modules/nf-core/fastqc' 
include { FASTP } from '../modules/nf-core/fastp'

include { MERGE } from '../modules/local/mergefq'

workflow FQPP {
    take:
     ch_fqs // queue: [mandatory] [ info, lane, fastq1, fastq2 ]
    main:
    versions = Channel.empty()
    // elongate fq
    fastqc_input_premerge = ch_fqs \
        | map {
                info, _lane, read1, read2 -> 
                tuple(info, [read1, read2])
        }

    FASTQC(fastqc_input_premerge)
    
    ch_grouped = ch_fqs.groupTuple(by: 0)
    MERGE(ch_grouped)

    fastqr_input = MERGE.out.reads \
        | map {
                info, read1, read2 -> 
                tuple(info, [read1, read2])
        }


    FASTP(fastqr_input, [], false, false, false)
    FASTQC2(FASTP.out.reads)

    versions = versions.mix(FASTP.out.versions)
    versions = versions.mix(FASTQC.out.versions)

    emit:
     fqreads = FASTP.out.reads
     versions
}
