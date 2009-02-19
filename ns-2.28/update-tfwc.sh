# Update TFWC/ns-2.28/tcp
# $Id$

for target in ibex echidna quokka wombat redkite hopback \
	saleem1 saleem2 saleem3 saleem4 saleem5
do

	echo "entering... $target"
	ssh $target "cd TFWC/ns-2.28 && svn update && make"
	echo "leaving... $target"

done

# NSF mounted systems
for target in turkey
do
    echo "entering... $target"
    ssh $target "cd /mnt/disk/soohyunc/TFWC/ns-2.28 && svn update && make"
    echo "leaving... $target"
done

for target in cockerel
do
    echo "entering... $target"
    ssh $target "cd /mnt/disk1/soohyunc/TFWC/ns-2.28 && svn update && make"
    echo "leaving... $target"
done

