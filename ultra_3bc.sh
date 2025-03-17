#!/usr/bin/env bash

#this is a ultraplex wrapper for 3'RNAseq data that has been p5/p7 demultiplexed into fastq files but needs further statification based on 3prime end barcodes (here RT-barcodes) 
#This script only allows one unique 5prime barcode per sample. The script produces temporary csv files that only check for the 5prime barcodes expected to be present in the fastq
#thereby reducing runtime on the server for experiments where many sampels are being match to several fastq files. Add ultraplex parameters as required
#This script requires csvgrep from the csvkit package, that needs to be installed in your active conda environment. conda install -c conda-forge csvkit

ml purge
barcodes="../ultraplex_3bc.csv"  #Metadatafile (see e.g. below script). Adjust path if needed

cd fastq || exit 1  # Exit if "fastq" directory is missing

#Adapt the filename pattern to be matched below
for g in *_merged_R1_001.fastq.gz; do
    # Extract base filename (everything before _merged_R1_001.fastq.gz)
    num="${g%_merged_R1_001.fastq.gz}"

    # Use csvkit to filter and format output properly. tail command to remove stubborn header row
    csvgrep -c 1 -m "$num" "$barcodes" | csvcut -c 2,3 | awk -F, '{print $1":"$2","}' | tail -n +2 > ../temp.csv

    # Run ultraplex
    ultraplex -i "$g" -b ../temp.csv -d "./ultraplex_$num" -l 18 --three_prime_only 
done

#metadatacsv example file:
#Filename,Barcode,Sample
#ZAG4476A1_S185,AAAAAAAAACCAG,RR_DMSO_1
#ZAG4476A1_S185,AAAAAAAAATTAC,RR_JQ1_3
