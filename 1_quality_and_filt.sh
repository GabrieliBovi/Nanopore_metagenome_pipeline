#!/bin/bash

###############################################################################
# STEP 1: Initial Quality Assessment
echo "STEP 1: Initial Quality Check"
###############################################################################

# (Optional) Create the Conda environment:
# conda create -y -n nanoquali python=3.8

# Activate Conda environment
echo "Activating Conda environment: nanoquali"
source ~/anaconda3/etc/profile.d/conda.sh
conda activate nanoquali

# (Optional) Install required tools:
# conda install -y -c bioconda nanoplot nanostat nanocomp

# Create output directories
echo "Creating output directories..."
mkdir -p initial_quality/nanoplot
mkdir -p initial_quality/nanocomp

# Define input directory
INPUT_DIR="/mnt/d/Tata_seq/raw"

# Run NanoPlot on each sample
for sample in "$INPUT_DIR"/*.fastq.gz; do
    name=$(basename "$sample" .fastq.gz)
    echo "Running NanoPlot for: $name"
    NanoPlot --fastq "$sample" -o initial_quality/nanoplot/"$name" -t 6
done

# Run NanoComp across all samples
echo "Running NanoComp for all samples..."
NanoComp --fastq "$INPUT_DIR"/*.fastq.gz --outdir initial_quality/nanocomp --plot violin -t 6

conda deactivate

###############################################################################
# STEP 2: Trimming and Filtering Reads
echo "STEP 2: Trimming and Filtering"
###############################################################################

# (Optional) Create the Conda environment, install porechop and nanofilt :
# Activate environment for trimming tools
echo "Activating Conda environment: nanotrim"
source ~/anaconda3/etc/profile.d/conda.sh
conda activate nanotrim

# Create output directories
echo "Creating output directories for filtered reads..."
mkdir -p filt_reads/porechop
mkdir -p filt_reads/nanofilt

# Run Porechop and NanoFilt on each sample
for sample in "$INPUT_DIR"/*.fastq.gz; do
    name=$(basename "$sample" .fastq.gz)

    echo "Trimming adapters with Porechop: $name"
    porechop -i "$sample" --threads 7 > "filt_reads/porechop/${name}_trimmed.fastq"

    echo "Filtering reads with NanoFilt: $name"
    NanoFilt --quality 10 --length 1200 --maxlength 1700 \
        < "filt_reads/porechop/${name}_trimmed.fastq" \
        > "filt_reads/nanofilt/${name}_filtered.fastq"
done

conda deactivate

###############################################################################
# STEP 3: Post-trimming Quality Assessment
echo "STEP 3: Post-trimming Quality Check"
###############################################################################

# Activate environment for quality tools
echo "Activating Conda environment: nanoquali"
source ~/anaconda3/etc/profile.d/conda.sh
conda activate nanoquali

# Create output directories
echo "Creating final quality output directories..."
mkdir -p qualidade_final/nanocomp
mkdir -p qualidade_final/nanoplot

# Run NanoPlot on each filtered sample
for sample in filt_reads/nanofilt/*_filtered.fastq; do
    name=$(basename "$sample" _filtered.fastq)
    echo "Running NanoPlot for: $name"
    NanoPlot --fastq "$sample" -o final_quality/nanoplot/"$name" -t 7
done

# Run NanoComp on all filtered reads
echo "Running NanoComp on filtered reads..."
NanoComp --fastq filt_reads/nanofilt/*_filtered.fastq --outdir final_quality/nanocomp --plot violin -t 7

conda deactivate

echo "Pipeline completed successfully."
