# Count the number of unique prefixes in .fastq.gz files
prefixes=($(find . -maxdepth 1 -type f -name "*_trim.fastq.gz" | sed 's|^\./||; s|_trim\.fastq\.gz$||' | sort -u))
num_prefixes=${#prefixes[@]}

echo "Number of unique prefixes: $num_prefixes"

# Prompt for output directory name
read -p "Enter the output directory name: " output_dir_name

# Loop through the unique prefixes
for ((i=0; i<num_prefixes; i++)); do
    prefix="${prefixes[i]}"
    echo "Processing files with prefix: $prefix"

    # Create a shell script file for this iteration
    script_file="bowtie_pipeline_$i.sh"

    # Create the output directory
    mkdir -p "./$output_dir_name"

    # Write the header to the script file
    echo "#!/bin/bash" > "$script_file"
    echo "#SBATCH --job-name=Bowtie2_$prefix" >> "$script_file"
    echo "#SBATCH --partition=super" >> "$script_file"
    echo "#SBATCH --nodes=1" >> "$script_file"
    echo "#SBATCH --time=0-02:00:00" >> "$script_file"
    echo "#SBATCH --output=./$output_dir_name/serialJob_$prefix.%j.out" >> "$script_file"
    echo "#SBATCH --error=./$output_dir_name/serialJob_$prefix.%j.time" >> "$script_file"
    echo "#SBATCH --mail-user=caiden.golder@utsouthwestern.edu" >> "$script_file"
    echo "#SBATCH --mail-type=ALL" >> "$script_file"
    echo "" >> "$script_file"
    echo "module load bowtie2/2.4.2" >> "$script_file"
    echo "module load samtools/1.6" >> "$script_file"
    echo "" >> "$script_file"
    echo "cd /project/InternalMedicine/Gruber_lab/s212170/Harsh/01092024_kallisto/trimmed/trimmed" >> "$script_file"

    # Append the Bowtie2 command to the SLURM job script
    echo "" >> "$script_file"
    echo "input_file=\"$PWD/${prefix}_trim.fastq.gz\"" >> "$script_file"
    echo "output_dir=\"$PWD/${output_dir_name}\"" >> "$script_file"
    echo "output_base=\"${prefix}_sorted\"" >> "$script_file"
    echo "" >> "$script_file"
    echo "bowtie2 -x GRCh38_noalt_as -U \"\$input_file\" -S \"\$output_dir/\$output_base.sam\" -p 8" >> "$script_file"
    echo "samtools view -bS \"\$output_dir/\$output_base.sam\" | samtools sort -o \"\$output_dir/\$output_base.bam\"" >> "$script_file"
    echo "samtools index \"\$output_dir/\$output_base.bam\"" >> "$script_file"

    # Submit the script as a batch job and delete it after completion
    sbatch "$script_file"
    echo "Submitted $script_file as a batch job"

    # Optionally, you can add a delay before deleting the script
    sleep 1 # Wait for a second to ensure the job has started

    # Delete the script after submission
    rm "$script_file"
    echo "Deleted $script_file"
done
