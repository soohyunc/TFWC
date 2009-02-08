# Update TFWC/exercise 
# $Id$

for target in ibex echidna narwhal dugong uakari quokka arkell wombat redkite planet saleem-01-b saleem-02-a saleem-03-a saleem-04-a saleem-05-a saleem-06-a saleem-07-a
do

echo "entering... $target"
ssh $target "cd TFWC/exercise && cvs update -d"
echo "leaving... $target"

done
