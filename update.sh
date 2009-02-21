# Update TFWC/exercise 
# $Id$

for target in	ibex.cs.ucl.ac.uk \
				echidna.cs.ucl.ac.uk \
				quokka.cs.ucl.ac.uk \
				corona.cs.ucl.ac.uk \
				wombat.cs.ucl.ac.uk \
				redkite.cs.ucl.ac.uk \
				hopback.cs.ucl.ac.uk \
				saleem1.cs.ucl.ac.uk \
				saleem2.cs.ucl.ac.uk \
				saleem3.cs.ucl.ac.uk \
				saleem4.cs.ucl.ac.uk \
				saleem5.cs.ucl.ac.uk
do
	echo "entering... $target"
	ssh $target "cd TFWC/exercise && svn update"
	echo "leaving... $target"
done

# NSF mounted systems
for target in turkey.cs.ucl.ac.uk
do
	echo "entering... $target"
	ssh $target "cd /mnt/disk/soohyunc/TFWC/exercise && svn update"
	echo "leaving... $target"
done

for target in cockerel.cs.ucl.ac.uk
do
	echo "entering... $target"
	ssh $target "cd /mnt/disk1/soohyunc/TFWC/exercise && svn update"
	echo "leaving... $target"
done

