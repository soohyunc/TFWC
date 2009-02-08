# Update TFWC/ns-2.28/tcp
# $Id$

for target in ibex echidna narwhal dugong uakari quokka arkell wombat redkite planet saleem-01-b saleem-02-a saleem-03-a saleem-04-a saleem-05-a saleem-06-a saleem-07-a
do

echo "entering... $target"
ssh $target "cd TFWC/ns-2.28 && cvs update update-tfwc.sh && cd tcp && cvs update && cd .. && make"
echo "leaving... $target"

done
