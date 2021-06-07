# this is the command file for dating the Thaum divergent time using ancient root + 3 additional calibrations

# estimate r_gene_gamma
#	input tree file:	03_iqtree.point.tre
#	input seq file:		03_seq.phy
#	input config file:	03_codonml.ctl
codeml 03_codonml.ctl

# create in.BV
#	input tree file:	00_iqtree.total.tre
#	input seq file:		00_seqs.phy
#	input config file:	01_mcmctree.ctl
mcmctree 01_mcmctree.ctl
mkdir 02_mcmctree
mv tmp0* 02_mcmctree
cd 02_mcmctree
cp ../wag.dat .
perl -e '@files=`ls tmp*ctl`;foreach $file (@files){chomp $file;if($file=~/(tmp\d+).ctl/){$tmp=$1;open OUT, ">$file";print OUT "seqfile = $tmp.txt\ntreefile = $tmp.trees\noutfile = $tmp.out\nnoisy = 3\nseqtype = 2\nmodel = 2\naaRatefile = ../wag.dat\nfix_alpha = 0\nalpha = 0.5\nncatG = 4\nSmall_Diff = 0.1e-6\ngetSE = 2\nmethod = 1\n"}}'
perl -e '@files=`ls tmp*ctl`;foreach $file (@files){chomp $file;$file=~s/\.ctl//;`mkdir $file`;`mv $file* $file/`;open OUT,">$file/$file.sh";print OUT "#!/bin/bash\n#SBATCH -n 1\ncd $file\n/home-user/xyfeng/database/paml/paml4.9h/src/codeml $file.ctl\n";`chmod +x $file/$file.sh`;`sbatch $file/$file.sh`;}'
cd ..
cat 02_mcmctree/tmp*/rst2 > ../in.BV

# run dating analysis
#	input tree file:	00_iqtree.sort.tre
#	input seq file:		00_seqs.phy
#	input config file:	04_mcmctree.ctl
perl -e 'foreach $run (1..2){`mkdir 04_run$run`;chdir "04_run$run";`cp ../in.BV ../04_mcmctree.ctl .`;open OUT, ">mcmc.sh";print OUT "#!/bin/bash\n#SBATCH -n 1\ntime /home-user/xyfeng/database/paml/paml4.9h/src/mcmctree 04_mcmctree.ctl\n";`chmod +x mcmc.sh`;`sbatch mcmc.sh`;chdir "..";}'

