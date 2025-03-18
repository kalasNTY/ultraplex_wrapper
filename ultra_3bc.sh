#!/usr/bin/env bash

# This script merges FASTQ files if necessary and runs ultraplex on the merged files.
# If _merged_ files already exist, the script will SKIP concatenation but continue ultraplex.
#this is a ultraplex wrapper for 3'RNAseq data that has been p5/p7 demultiplexed into fastq files but needs further statification based on 3prime end barcodes (here RT-barcodes) 
#This script only allows one unique 3prime barcode per sample. The script produces temporary csv files that only check for the 3prime barcodes expected to be present in the fastq
#thereby reducing runtime on the server for experiments where many sampels are being match to several fastq files. Add ultraplex parameters as required
#This script requires csvgrep from the csvkit package, that needs to be installed in your active conda environment. conda install -c conda-forge csvkit

# Directory containing fastq files
FASTQ_DIR="./fastq"
BARCODES="../ultraplex_3bc.csv"  # Metadata file, adjust path if needed

cd "$FASTQ_DIR" || exit 1  # Exit if "fastq" directory is missing

# Check if merged files exist
MERGED_EXISTS=false
if ls *_merged_R1_001.fastq.gz 1>/dev/null 2>&1; then
    echo "Merged FASTQ files already exist. Skipping concatenation."
    MERGED_EXISTS=true
fi

# If no merged files exist, perform concatenation
if [ "$MERGED_EXISTS" = false ]; then
    for file in *_L001_R1_001.fastq.gz; do
        sample_prefix="${file%%_L001_R1_001.fastq.gz}"  # Extract sample name prefix

        # Define filenames
        file_L001_R1="${sample_prefix}_L001_R1_001.fastq.gz"
        file_L002_R1="${sample_prefix}_L002_R1_001.fastq.gz"
        output_file_R1="${sample_prefix}_merged_R1_001.fastq.gz"

        file_L001_R2="${sample_prefix}_L001_R2_001.fastq.gz"
        file_L002_R2="${sample_prefix}_L002_R2_001.fastq.gz"
        output_file_R2="${sample_prefix}_merged_R2_001.fastq.gz"

        # Merge Read 1 files if multiple lanes exist
        if [[ -f "$file_L001_R1" && -f "$file_L002_R1" ]]; then
            echo "Merging $file_L001_R1 and $file_L002_R1 into $output_file_R1"
            cat "$file_L001_R1" "$file_L002_R1" > "$output_file_R1"
        elif [[ -f "$file_L001_R1" ]]; then
            echo "Single R1 file found for $sample_prefix, renaming to merged format."
            mv "$file_L001_R1" "$output_file_R1"
        fi

        # Merge Read 2 files if multiple lanes exist
        if [[ -f "$file_L001_R2" && -f "$file_L002_R2" ]]; then
            echo "Merging $file_L001_R2 and $file_L002_R2 into $output_file_R2"
            cat "$file_L001_R2" "$file_L002_R2" > "$output_file_R2"
        elif [[ -f "$file_L001_R2" ]]; then
            echo "Single R2 file found for $sample_prefix, renaming to merged format."
            mv "$file_L001_R2" "$output_file_R2"
        fi
    done
fi

# Ensure ultraplex runs, regardless of whether merging happened
echo "Running ultraplex..."

# Clear previous all_ultra.csv file if it exists
> ../all_ultra.csv  # This creates/clears the file

# Run ultraplex on merged files
for g in *_merged_R1_001.fastq.gz; do
    num="${g%_merged_R1_001.fastq.gz}"  # Extract sample name

    # Generate temp.csv (skip header row)
    csvgrep -c 1 -m "$num" "$BARCODES" | csvcut -c 2,3 | awk -F, '{print $1":"$2","}' | tail -n +2 > ../temp.csv

    # Append to all_ultra.csv
    cat ../temp.csv >> ../all_ultra.csv

    # Run ultraplex
#    ultraplex -i "$g" -b ../temp.csv -d "./ultraplex_$num" -l 18 --three_prime_only
done

echo "Ultraplex processing complete. Combined barcode file saved as all_ultra.csv."

#metadatacsv example file (ultraplex_3bc.csv):
#Filename,Barcode,Sample
#ZAG4476A1_S185,AAAAAAAAACCAG,RR_DMSO_1
#ZAG4476A1_S185,AAAAAAAAATTAC,RR_JQ1_3
