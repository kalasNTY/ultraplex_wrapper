# Ultraplex Wrapper for 3' RNA-seq Data

## Overview
This script is a wrapper for **Ultraplex**, designed for **3' RNA-seq** data that has already been **P5/P7 demultiplexed** into FASTQ files but requires further stratification based on **3' end barcodes** (RT-barcodes). 

### Features:
- **Automatically merges FASTQ files** across lanes (_L001, L002_) for each sample.
- **Supports Read 1 (`_R1_001.fastq.gz`) and Read 2 (`_R2_001.fastq.gz`).**
- **Skips merging** if `_merged_` files already exist but **still runs ultraplex**.
- **Generates temporary CSV files** to check for 3' barcodes.
- **Reduces server runtime** for large-scale experiments.
- **Requires `csvgrep` from `csvkit` package** (install via `conda install -c conda-forge csvkit`).

## Installation
Ensure `csvkit` is installed:
```bash
conda install -c conda-forge csvkit
```

## Usage
### 1. Prepare FASTQ Directory
Place all FASTQ files in a directory (default: `fastq/`).

### 2. Prepare Barcode File
Create a **barcode metadata file** (`ultraplex_3bc.csv`) with expected **3' RT-barcodes**.

### 3. Run the Script
Execute the script to **merge FASTQ files (if necessary) and run ultraplex**:
```bash
bash ultraplex_wrapper.sh
```

### 4. Output Files
- Merged FASTQ files: `*_merged_R1_001.fastq.gz` and `*_merged_R2_001.fastq.gz`
- Barcode metadata file: `all_ultra.csv`
- Ultraplex output directories: `./ultraplex_<sample_name>/`

## Script Logic
### Merging FASTQ Files
- If `_merged_` files **already exist**, merging is skipped.
- If multiple lanes (`_L001_`, `_L002_`) exist, they are concatenated.
- If only a single lane exists, it is renamed to `_merged_` format.

### Running Ultraplex
- **All samples** (merged or not) are processed using **Ultraplex**.
- Generates `temp.csv` for barcode selection.
- Creates `all_ultra.csv` containing all barcode mappings.

## Example Barcode File Format (`ultraplex_3bc.csv`)
```
Sample_ID, Barcode, Length
SampleA, ACGTAC, 18
SampleB, TGCACT, 18
```

## Troubleshooting
- Ensure `csvkit` is installed in your **active Conda environment**.
- Check that the `fastq/` directory contains expected files.
- If ultraplex fails, verify that `ultraplex_3bc.csv` contains correct **barcodes and sample names**.

## License
MIT License

---
This script was developed to streamline 3' RNA-seq barcode processing and can be adapted as needed. Contributions are welcome!
