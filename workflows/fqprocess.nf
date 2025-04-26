
// fqs
include { FASTQC } from '../modules/nf-core/fastqc' 
include { FASTQC as FASTQC1} from '../modules/nf-core/fastqc' 
include { FASTQC as FASTQC2} from '../modules/nf-core/fastqc' 
include { FASTP } from '../modules/nf-core/fastp'

workflow FQPP {
    take:
     ch_fqs // queue: [mandatory] [ info, lane, fastq1, fastq2 ]
    main:
    versions = Channel.empty()
    // elongate fq
    fastqc_input = ch_fqs \
        | map {
                info, lane, read1, read2 -> 
                info["lane"] = lane
                tuple(info, [read1, read2])
        }

    FASTQC(fastqc_input)
    FASTP(fastqc_input, [], false, false, false)
    FASTQC2(FASTP.out.reads)

    versions = versions.mix(FASTP.out.versions)
    versions = versions.mix(FASTQC.out.versions)

    emit:
     fqreads = FASTP.out.reads
     versions
}
