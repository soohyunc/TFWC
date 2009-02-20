# Update TFWC/exercise 
# $Id$

for target in ibex echidna quokka wombat redkite hopback \
		saleem1 saleem2 saleem3 saleem4 saleem5 hen
do
	echo "entering... $target"
	ssh $target "cd TFWC/exercise/comp_05.1/add-on/ && make && cd && cd TFWC/exercise/comp_05.2/add-on/ && make"
	echo "leaving... $target"
	echo ""
done

# NSF mounted systems
for target in turkey
do
	echo "entering... $target"
	ssh $target "cd /mnt/disk/soohyunc/TFWC/exercise/comp_05.1/add-on/ && make && cd && cd /mnt/disk/soohyunc/TFWC/exercise/comp_05.2/add-on/ && make"
	echo "leaving... $target"
	echo ""
done

for target in cockerel
do
	echo "entering... $target"
	ssh $target "cd /mnt/disk1/soohyunc/TFWC/exercise/comp_05.1/add-on/ && make && cd && cd /mnt/disk1/soohyunc/TFWC/exercise/comp_05.2/add-on/ && make"
	echo "leaving... $target"
	echo ""
done

