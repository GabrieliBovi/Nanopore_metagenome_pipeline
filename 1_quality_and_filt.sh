#!/bin/bash

# Enable Conda commands
source ~/anaconda3/etc/profile.d/conda.sh

###############################################################################
# STEP 1: Initial Quality Assessment
echo "STEP 1: Initial Quality Check"
###############################################################################

# (Optional) Create the Conda environment:
# conda create -y -n nanoquali python=3.8
# conda install -y -n nanoquali -c bioconda nanoplot nanostat nanocomp

# Activate Conda environment
echo "Activating Conda environment: nanoquali"
conda activate nanoquali

# Create output directories
echo "Creating output directories for initial quality..."
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

# (Optional) Create the Conda environment:
# conda create -y -n nanotrim python=3.8
# conda install -y -n nanotrim -c bioconda porechop nanofilt
# conda install bioconda::filtlong

# Activate environment for trimming tools
echo "Activating Conda environment: nanotrim"
conda activate nanotrim

# Create output directories
echo "Creating output directories for filtered reads..."
mkdir -p filt_reads/porechop
mkdir -p filt_reads/nanofilt

# Run Porechop and NanoFilt on each sample
for sample in "$INPUT_DIR"/*.fastq.gz; do
    name=$(basename "$sample" .fastq.gz)

    echo "Trimming adapters with Porechop: $name"
   # porechop -i "$sample" --threads 7 > "filt_reads/porechop/${name}_trimmed.fastq"

    echo "Filtering reads with NanoFilt: $name"
    NanoFilt --quality 9 --length 1200 --maxlength 1700 \
        < "filt_reads/porechop/${name}_trimmed.fastq" \
        > "filt_reads/nanofilt/${name}_filt.fastq"
done

conda deactivate

###############################################################################
# STEP 3: Post-trimming Quality Assessment
echo "STEP 3: Post-trimming Quality Check"
###############################################################################

# Activate environment for quality tools
echo "Activating Conda environment: nanoquali"
conda activate nanoquali

# Create output directories
echo "Creating output directories for final quality..."
mkdir -p final_quality/nanocomp
mkdir -p final_quality/nanoplot

# Run NanoPlot on each filtered sample
for sample in filt_reads/nanofilt/*_filt.fastq; do
    name=$(basename "$sample" _filt.fastq)
    echo "Running NanoPlot for: $name"
    NanoPlot --fastq "$sample" -o final_quality/nanoplot/"$name" -t 7
done

# Run NanoComp on all filtered reads
echo "Running NanoComp on filtered reads..."
NanoComp --fastq filt_reads/nanofilt/*_filt.fastq --outdir final_quality/nanocomp --plot violin -t 7

conda deactivate

echo "Pipeline completed."
