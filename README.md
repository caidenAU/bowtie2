# bowtie2
Pipeline for mapping fastq.gz files against GRCh38 reference


Ensure you change the working directory on page 35.
Also you need the 6 .bt2 references in the current directory.
If you need these, run this command
```
wget https://genome-idx.s3.amazonaws.com/bt/GRCh38_noalt_as.zip
unzip *
```

For this script, all files are assumed to be coming from the cutadapt pipeline and should end in " *_trim.fastq.gz " 

The script will count the unique prefixes in the current directory, and prompt an output folder. It will then generate a temporary script that can be submitted to the slurm scheduler to process in parallel. Each script will map one trimmed fastq file against the GRCh38 reference, and output as SAM file. These are huge so we convert to BAM using samtools/1.6. Then you need to sort the BAM in samtools, and finally you can generate an index file (.bam.bai) which needs to be downloaded with the bam in order to view in IGV.

I chose to run in multithreaded mode set to 8 cores. This is based on others' benchmarking https://www.jefftk.com/p/benchmarking-bowtie2-threading but feel free to play with this. "super" compute cores should have 48-72 cores available.
