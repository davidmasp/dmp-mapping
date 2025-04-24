

process MERGE {
    input:
    tuple val(meta), val(lanes), path(reads1), path(reads2)

    output:
    tuple val(meta), path("${meta.id}_mergedr1.fastq.gz"), path("${meta.id}_mergedr2.fastq.gz"), emit: reads

    script:
    """
    cat ${reads1} > ${meta.id}_mergedr1.fastq.gz
    cat ${reads2} > ${meta.id}_mergedr2.fastq.gz 
    """
}

