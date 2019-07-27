# Prepare ligand files for docking with AutoDock Vina.

# Trott O, Olson AJ.
# AutoDock Vina: improving the speed and accuracy of docking
# with a new scoring function, efficient optimization and
# multithreading. J. Comput. Chem. 2010;31(2):455-461.
# doi:10.0112/jcc.21334

#!/bin/bash
#PBS -N rowec_ligand_prep
#PBS -l select=1:ncpus=8:mem=8gb
#PBS -q wsuq

# Create output directory if it doesn't exist
mkdir -p output/

cd ligand/

### If needed, convert mol2 files to pdbqt
for f in *.mol2; do
	b=$(basename $f .mol2)
	output=$b.pdbqt
    echo Converting ligand $f
	echo Saving as $output
    obabel -imol2 $f -O $output
	rm $f &
done

wait

### If needed, uncompress pdbqt files
for f in *.pdbqt.gz; do
    echo Uncompressing ligand $f
    gunzip $f &
done

wait

### If needed, split pdbqt files
for f in *.pdbqt; do
   echo Splitting ligand $f
   vina_split --input $f
   rm $f &
done

wait

### Arrange ligands into directories containing no more than 290 files each
n=0
echo Arranging ligand subdirectories...
for f in *.pdbqt; do
  d=$(printf %01d $((i/290+1)))
  mkdir -p $d
  mv "$f" $d
  let i++
done

echo Done.