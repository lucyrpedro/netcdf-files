#!/bin/bash

# ESDM install document for archer
# Run it on /home

# Target must live on Archer on the work directory as home isn't accessible
TGT=/work/n02/n02/grenvill/esdm/install
export WORK=/work/n02/n02/grenvill
# Jansson
wget https://digip.org/jansson/releases/jansson-2.13.1.tar.bz2
tar -xf jansson*
cd jansson-2.13.1/
./configure  --prefix=$TGT
make -j install
cd ..

# meson + ninja for build of GLIB2

module load cray-python/3.8.5.0
pip install meson
pip install ninja
export PATH=$PATH:$HOME/.local/bin/

# GLIB2
wget https://gitlab.gnome.org/GNOME/glib/-/archive/2.67.1/glib-2.67.1.tar.bz2
tar -xf glib*
cd glib-2.67.1/
$HOME/.local/bin/meson build --prefix=$TGT
cd build
ninja install
cd ../../

# ESDM NetCDF requirements
# HDF5
wget https://support.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.10.5.tar.gz
tar -xzf hdf5*.gz
cd hdf5-1.10.5
./configure --enable-parallel --prefix=$TGT CC=cc
make -j install
cd ..

# ESDM
git clone --recurse-submodules https://github.com/ESiWACE/esdm.git
export PATH=$PATH:$TGT/bin
export PKG_CONFIG_PATH=$TGT/lib/pkgconfig/:$TGT/lib64/pkgconfig/:$PKG_CONFIG_PATH
cd esdm
./configure --prefix=$TGT
cd build
make -j install
cd ../../

# ESDM NetCDF
# git clone --recurse-submodules https://github.com/ESiWACE/esdm-netcdf.git
# cd esdm-netcdf 
git clone --recurse-submodules https://github.com/ESiWACE/netcdf-c.git
cd netcdf-c
cp /home/n02/n02/lrpedro/configure.ac configure.ac
autoreconf -i
mkdir build
cd build
../configure --prefix=$TGT --with-esdm=$TGT CC=cc  --disable-dap
# Somehow the Cray compiler does not inherit the library dependencies from so files
make -j install LDFLAGS="-L$TGT/lib/ -lsmd -ljansson"
cd ../../

# Testing with NetCDF bench
git clone https://github.com/joobog/netcdf-bench.git
cd netcdf-bench/
cmake -DNETCDF_INCLUDE_DIR=$TGT/include  -DNETCDF_LIBRARY=$TGT/lib/libnetcdf.so
make
cp ./src/benchtool $TGT/bin
cd ..

# cp esdm.conf
cp $HOME/esdm/build/src/test/esdm.conf $TGT

# Prepare testrun
cd $WORK
mkdir test-esdm-slurm
cd test-esdm-slurm
cp $HOME/esdm/build/src/test/esdm.conf .

cat > test.slurm << EOF
#!/bin/bash
#SBATCH --job-name=esdm
#SBATCH --time=0:10:0
#SBATCH --nodes=2
#SBATCH --tasks-per-node=2
#SBATCH --cpus-per-task=4
#SBATCH --account=n02-cms
#SBATCH --partition=standard
#SBATCH --qos=standard
export PATH=$TGT/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cray/libfabric/1.11.0.0.233/lib64/
ldd $(which benchtool)
mkfs.esdm --ignore-errors --remove --create -g -l
srun --hint=nomultithread --distribution=cyclic:cyclic benchtool -w -r -f="esdm://out" -p=2 -n=2
# mkfs.esdm --ignore-errors --remove --create -g -l
EOF

cat > test-verify.slurm << EOF
#!/bin/bash
#SBATCH --job-name=esdm
#SBATCH --time=0:10:0
#SBATCH --nodes=2
#SBATCH --tasks-per-node=2
#SBATCH --cpus-per-task=4
#SBATCH --account=n02-cms
#SBATCH --partition=standard
#SBATCH --qos=standard
export PATH=$TGT/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cray/libfabric/1.11.0.0.233/lib64/
ldd $(which benchtool)
mkfs.esdm --ignore-errors --remove --create -g -l
srun --hint=nomultithread --distribution=cyclic:cyclic benchtool -w -r --verify -f="esdm://out" -p=2 -n=2
# mkfs.esdm --ignore-errors --remove --create -g -l
EOF

echo "Now submitting test.slurm files!"

sbatch test.slurm
sbatch test-verify.slurm

echo "Please, check the slurm*.out files in $WORK/test-esdm-slurm!"

cd $WORK/test-esdm-slurm

# Clean the installation

rm -rf $HOME/esdm
rm -rf $HOME/glib*
rm -rf $HOME/hdf5*
rm -rf $HOME/jansson*
rm -rf $HOME/netcdf-*
# rm -rf $WORK/esdm
# rm -rf $WORK/test-esdm-slurm