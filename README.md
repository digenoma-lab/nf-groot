![Language: Nextflow](https://img.shields.io/badge/Language-Nextflow-green.svg)

# nf-groot

A [Nextflow](https://www.nextflow.io/) pipeline for running [Groot](https://github.com/will-rowe/groot), which is a tool to type Antibiotic Resistance Genes (ARGs) in metagenomic samples.

## Input samples

The input for the pipeline is a set of reads given as pairs. For example:

```
17.R1.fq.gz
17.R2.fq.gz
S7.350.R1.fq.gz
S7.350.R2.fq.gz
...
```

## Running in Nextflow

Check usage:

```
nextflow run iamgroot.nf --help
```

Search for the sample reads ```S15_350```, using the ```arg-annot``` default database (```db-arg```) executed in a distributed environment (check our [DiGenomaLab](https://digenoma-lab.cl/facilities/cluster/) cluster).

```
nextflow -bg run iamgroot.nf --reads 'reads/17.R{1,2}.fq.gz' -c nextflow.config -profile kutral
```

## Software versions

* Groot: 1.1.2
* Nextflow: 23.04.2
