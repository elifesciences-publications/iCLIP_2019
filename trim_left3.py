'''
Created on Jan. 30 2017 

@author: Tu Lu modified from Nejc Haberman 


The script will read fasta file and remove the left 3-nt random barcode from fasta for demultiplexing with FASTX tool. Random barcode will be saved in the header of fasta file.
'''


import sys

def swap_barcodes(fin_fasta, fout_fasta):
    finFasta = open(fin_fasta, "rt")
    foutFasta = open(fout_fasta, "w")
    line = finFasta.readline()
    while line:
        if line[0] != '>':
            randomBarcode = line[0:3]            
           
            seqRead = line[3:]

            foutFasta.write(">"+randomBarcode + '\n')
            foutFasta.write(seqRead)
        line = finFasta.readline()
    finFasta.close()
    foutFasta.close()

if sys.argv.__len__() == 3:
    fin_fasta = sys.argv[1]
    fout_fasta = sys.argv[2]
    swap_barcodes(fin_fasta, fout_fasta)
else:
    print "usage: python swap_barcode_to_header1.py inputfilename outputfilename"
    quit()

