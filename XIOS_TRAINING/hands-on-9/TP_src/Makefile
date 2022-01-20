# Compilateur
FC = mpif90
# Variables
XIOS_DIR = ../xios_build
# Includes
FCFLAGS= -I$(XIOS_DIR)/inc  -I$(NETCDF_INCDIR)
# Librairies
LDFLAGS = -L$(XIOS_DIR)/lib -lxios $(NETCDF_LIBS) -lstdc++

all: generic_testcase

%: %.o
	$(FC) -o $@.exe $^ $(LDFLAGS)

%.o: %.f90
	$(FC) $(FCFLAGS) -c $<

clean:
	rm -f *.exe
	rm -f *.o *.mod *.MOD
	rm -f xios_client_*.out
	rm -f xios_client_*.err
