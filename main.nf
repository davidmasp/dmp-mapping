
// index like
params.fqindex = "index.csv"

// the info field should have two mandatory fields:

// reference genome
params.genome = "genome.fa"
params.fai = "genome.fa.fai"

params.bwaindex = null

include { FQPP } from './workflows/fqprocess'
include { MAP } from './workflows/mapping'

workflow  {
    fasta_file = file(params.genome)
    fai_file = file(params.fai)

    fq_ch = Channel.fromPath(params.fqindex) \
        | splitCsv(header:true) \
        | map { row-> tuple(row.info, row.lane, file(row.read1), file(row.read2)) } \
        | map {
            info, lane,read1, read2 -> 
                def meta = [:]
                def tokens = info.split(":")
                tokens.each { tok ->
                    def to = tok.split("=")
                    meta[to[0]] = to[1]
                }
            tuple(meta, lane, read1, read2)
        } 
    
    FQPP(fq_ch)
    // params.bwaindex is needed here too!
    MAP(
        FQPP.out.fqreads,
        fasta_file,
        fai_file
    )

}
