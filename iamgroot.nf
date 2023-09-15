#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Usage
def help_msg() {
	help = """[nf-groot]: A nextflow pipeline for running Groot
		|A tool to type Antibiotic Resistance Genes (ARGs)
		|
		|  https://github.com/will-rowe/groot
		|
		|Usage:
		|  --reads   path to a pair of reads given in fasta format (i.e: '*{1,2}.fq.gz')
		|            [default: none]
		|
		|Optional arguments:
		|  --db      database directory of MSA graphs <path-to/database>
		|            [default: ${params.db_arg}]
		|  --outdir  directory to save results
		|            [default: ${params.outdir}]
		|
		|Print help:
		|  nextflow run iamgroot.nf --help
		|
		|Examples of execution:
		|  nextflow -bg run iamgroot.nf --reads '17.R{1,2}.fq.gz' -c nextflow.config -profile kutral
		|  nextflow -bg run iamgroot.nf --reads '../reads/*.R{1,2}.fq.gz' -c nextflow.config -profile kutral
		|
		""".stripMargin()
	println help
	exit 0
}

// Run groot align
process IAMGROOT {
	publishDir "${params.outdir}/${sample}", mode: "copy"
	tag "${sample}" // (ie. '17.R' **remove'.R'**)
	
	input:
	tuple val(sample), path(read1), path(read2)
	path db
	
	output:
	tuple val(sample), path("${sample}_reads.bam"), emit: bam
	path("groot_version.txt")                     , emit: version
	path("groot.log")                             , emit: log
	
	script:
	if (params.debug == true) {
		"""
		#!/bin/bash
		
		# Call conda profile
		source /mnt/beegfs/home/mrojas/miniconda3/etc/profile.d/conda.sh
		
		# Activate env
		conda activate base
		groot version > groot_version.txt
		conda deactivate
		
		# Test params
		echo groot align -i $db -f $read1,$read2 -t 0.95 -p ${task.cpus} > ${sample}_reads.bam
		touch ${sample}_reads.bam
		touch groot_version.txt
		touch groot.log
		"""
	}
	else {
		"""
		#!/bin/bash
		
		# Call conda  profile
		source /mnt/beegfs/home/mrojas/miniconda3/etc/profile.d/conda.sh
		
		# Activate env and run
		conda activate base
		groot version > groot_version.txt
		groot align -i $db -f $read1,$read2 -t 0.95 -p ${task.cpus} > ${sample}_reads.bam
		conda deactivate
		touch groot.log
		"""
	}
}

workflow {
	// Check args
	if (params.help || params.reads == "") {
		help_msg()
	}
	
	// Assign database
	groot_db = params.db
	if (params.db == null) {
		groot_db = params.db_arg
	}
	
	// Process input reads
	Channel
		.fromFilePairs( params.reads, flat: true )
		.map{ it -> [ it[0], it[1], it[2] ] }
		.groupTuple()
		.set { reads_ch }
	reads_ch.view()
	
	IAMGROOT( reads_ch, file(groot_db) )
}
// nextflow -bg run iamgroot.nf --reads '17.R{1,2}.fq.gz' --db db-arg -c nextflow.config -profile kutral {-resume}
