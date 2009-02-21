# Update TFWC/ns-2.28/tcp
# $Id$

for target in	ibex.cs.ucl.ac.uk \
				echidna.cs.ucl.ac.uk \
				quokka.cs.ucl.ac.uk \
				wombat.cs.ucl.ac.uk \
				redkite.cs.ucl.ac.uk \
				hopback.cs.ucl.ac.uk \
				saleem1.cs.ucl.ac.uk \
				saleem2.cs.ucl.ac.uk \
				saleem3.cs.ucl.ac.uk \
				saleem4.cs.ucl.ac.uk \
				saleem5.cs.ucl.ac.uk \
				corona.cs.ucl.ac.uk \
				quokka.cs.ucl.ac.uk
do

	echo "entering... $target"
	ssh $target "cd TFWC/ns-2.28 && svn update && make"
	echo "leaving... $target"

done

# NSF mounted systems
for target in turkey.cs.ucl.ac.uk
do
    echo "entering... $target"
    ssh $target "cd /mnt/disk/soohyunc/TFWC/ns-2.28 && svn update && make"
    echo "leaving... $target"
done

for target in cockerel.cs.ucl.ac.uk
do
    echo "entering... $target"
    ssh $target "cd /mnt/disk1/soohyunc/TFWC/ns-2.28 && svn update && make"
    echo "leaving... $target"
done

