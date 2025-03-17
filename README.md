This is a ultraplex wrapper for 3'RNAseq data that has been p5/p7 demultiplexed into fastq files but needs further statification based on 3prime end barcodes (here RT-barcodes) 
This script only allows one unique 3prime barcode per sample. The script produces temporary csv files that only check for the 3prime barcodes expected to be present in the fastq
thereby reducing runtime on the server for experiments where many sampels are being match to several fastq files. Add ultraplex parameters as required
This script requires csvgrep from the csvkit package, that needs to be installed in your active conda environment. conda install -c conda-forge csvkit
