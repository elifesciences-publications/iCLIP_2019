# iCLIP_2019
ICLIP analysis for MEG-3 and PGL-1
for trim_last2.py and trim_left3.py, there two file were orginaly written by Nejc Haberman from Ule lab.
https://github.com/jernejule/non-coinciding_cDNA_starts


by Sean Lee and Tu Lu
####Sometimes we found that there are null sequences information within sequencing reads. If there is a empty (null) sequence that prevent fastx_toolkits to work, Try to remove these sequences by doing the following.

### This code is associated with the paper from Lee et al., "Recruitment of mRNAs to P granules by condensation with intrinsically-disordered proteins". eLife, 2020. http://dx.doi.org/10.7554/eLife.52896

1. replace null character with "~": # example sequencing file named HNNM3BCXY_1_0_1.fastq
    sed -i.bak 's/\x0/~/g' HNNM3BCXY_1_0_1.fastq 
2. delete lines with "~" and 2 line below:  
    sed -i.bak '/~~~~~~~~~/,+2d' HNNM3BCXY_1_0_1.fastq 
3. remove empty sequences  
    bioawk -cfastx 'length($seq) > 1 {print "@"$name"\n"$seq"\n+\n"$qual}' tmp.fastq > new.fastq 


#### Try to remove adapter, demultiplexing and remove duplicated reads from PCR reaction.—iCLIP_to_hisat.sh 
####  must have in the same folder: trim_left3.py, trim_last2.py, and barcod.txt
1. After unzipped the fastq files: 
    - fastx_clipper to clipper adapter and discrad the sequences that are shorter then 10 nt + 5 random barcode + 4 nt barcode.  
      Two files are geneated: reads contain intact adapters ( e.g shorter cDNA) and reads do not contain adapter (e.g longer reads) 
2. After remove adaptor, convert fastq to fasta to following process. 
3. Using python code "trim_left3.py" to swap random barcodes to headers of fasta file. 
4. demultiplex, reads with unmached barcodes will be discarded. 
5. Using python code " Trim_last2.py" to swap the last 2 nt degenerative seq to the header 
6. align the reads by hisat2. 
7. filter reads with more than 2 mismatches. 
8. remove duplicates 

##### Use samtools to convert sam to bam
To visualize mapped reads in  IGV 
1. SAM to BAM 
2. To sort Bam file 
3. To index .sorted. bam files 
Now can load .sorted.bam onto IGV for visualzation 

##### To count reads using HTseq for the following analysis.  
Use Htseq to make genecount file. If I want to make count file using CDS and UTR separately, just need to use different reference file to HTseq-count.
The basic command line is as following:

for file in ./*.sam
do htseq-count -o "${file/}" "$file" [reference gtf file] > "${file/%.sam/filename.genecount}"
done

After making different count table. Merge count table the further analysis.
