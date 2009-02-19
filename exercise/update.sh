# Update TFWC/exercise 
# $Id$

for target in ibex echidna quokka wombat redkite hopback \
		saleem1 saleem2 saleem3 saleem4 saleem5 hen
do
	echo "entering... $target"
	ssh $target "cd TFWC/exercise && svn update"
	echo "leaving... $target"
done

# NSF mounted systems
for target in turkey
do
	echo "entering... $target"
	ssh $target "cd /mnt/disk/soohyunc/TFWC/exercise && svn update"
	echo "leaving... $target"
done

for target in cockerel
do
	echo "entering... $target"
	ssh $target "cd /mnt/disk1/soohyunc/TFWC/exercise && svn update"
	echo "leaving... $target"
done

