

process MERGEBAM {
    input:
    tuple val(meta), val(lanes), path(reads1), path(reads2)

    output:
    tuple val(meta), path("${meta.id}_mergedr1.fastq.gz"), path("${meta.id}_mergedr2.fastq.gz"), emit: reads

    script:
    """
    exit 1
    """
}

