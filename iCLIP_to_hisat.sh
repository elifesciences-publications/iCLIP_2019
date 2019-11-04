##must haves: trim_left3.py, trim_last2.py clee135_139399_barcode.txt
#!/bin/bash -l

#$ -l h_vmem=16G
#$ -l tmem=16G
#$ -l h_rt=32:0:0
#$ -j y
#$ -S /bin/bash

# list of all tools
export PATH=/home/seydouxlab/Downloads/hisat2-2.0.5:$PATH
data=$1
path=`pwd -P`


# clip the adapter and discard clipped sequences and discard the sequences that are shorter then 10 nt + 5 random barcode + 4 experimental barcode; complete cDNAs contains the adapter sequence and incomplete does not
fastx_clipper -Q 33 -a AGATCGGAAG -C -n -l 19 -i cleaned_1107_clee135_139399.fastq -o incomplete.fq
fastx_clipper -Q 33 -a AGATCGGAAG -c -n -l 19 -i cleaned_1107_clee135_139399.fastq -o complete.fq

###### we found there were some empty sequences that marked with ^@^@^@^@^@^@....
##  please refer to readme for the solution.

# fastq to fasta
fastq_to_fasta -Q 33 -n -i incomplete.fq -o incomplete.fa
fastq_to_fasta -Q 33 -n -i complete.fq -o complete.fa
rm incomplete.fq
rm complete.fq

# swap the first 3 nu random barcodes to headers of fasta file
python trim_left3.py incomplete.fa incomplete-barcodes.fa
python trim_left3.py complete.fa complete-barcodes.fa
rm incomplete.fa
rm complete.fa

# demultiplex, reads with unmached barcodes will be discarded 
cat incomplete-barcodes.fa | fastx_barcode_splitter.pl --bcfile clee135_139399_barcode.txt --bol --prefix "incomplete_" --suffix ".fa" --mismatches 2 > incomplete-demultiplex.txt 
cat complete-barcodes.fa | fastx_barcode_splitter.pl --bcfile clee135_139399_barcode.txt --bol --prefix "complete_" --suffix ".fa" --mismatches 2 > complete-demultiplex.txt 
rm incomplete-barcodes.fa
rm complete-barcodes.fa

# swap the last 2 nt degenerative seq to the header
python trim_last2.py complete_BC164_0718_nos2.fa co_BC164_0718_nos2.fa
python trim_last2.py complete_BC165_0718_m3.fa co_BC165_0718_m3.fa
python trim_last2.py complete_BC167_Tu_m1.fa co_BC167_Tu_m1.fa
python trim_last2.py complete_BC169_0819_pgl1.fa co_BC169_0819_pgl1.fa
python trim_last2.py complete_BC168_0819_m3.fa co_BC168_0819_m3.fa
rm complete_*.fa

python trim_last2.py incomplete_BC164_0718_nos2.fa in_BC164_0718_nos2.fa
python trim_last2.py incomplete_BC165_0718_m3.fa in_BC165_0718_m3.fa
python trim_last2.py incomplete_BC167_Tu_m1.fa in_BC167_Tu_m1.fa
python trim_last2.py incomplete_BC169_0819_pgl1.fa in_BC169_0819_pgl1.fa
python trim_last2.py incomplete_BC168_0819_m3.fa in_BC168_0819_m3.fa
rm incomplete_*.fa

#align the reads by hisat2
for file in ./*.fa
do hisat2 -x ~/Documents/Caenorhabditis_elegans/UCSC/ce10/Sequence/Chromosomes/ce10 -S "${file/%fa/sam}" -f "$file" --known-splicesite-infile /home/seydouxlab/Downloads/hisat2-2.0.5/elegans_splicesites.txt --no-softclip
done

# filter reads with more than 2 mismatches
for file in ./*.sam
do samtools view -Sh "$file" | grep -e "^@" -e "XM:i:[012][^0-9]" > "${file/%.sam/-2mis.sam}"
done

# remove duplicates
for file in ./*-2mis.sam;
do (head -n 9 "$file" && tail -n +10 "$file" | sort | uniq) > "${file/%.sam/-uniq.sam}"
done

##########################################################################



