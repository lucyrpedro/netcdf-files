OBJS=llist.o main.o malloc.o message.o ncbits.o stats.o tprob.o
EXE=ncensemble

# assume netcdf installation is in parent directory of the directory
# containing the ncdump executable.  if not, override with 
# "make NETCDF=....."
NETCDF=$(shell dirname `which ncdump`)/../

ifeq ($(shell id -u), 0)
installdir=/usr/local/bin
else
installdir=$(HOME)/bin
endif

ifeq ($(CC), gcc)
CFLAGS=-Wall -O
else
CFLAGS=-O
endif

all: $(EXE)

$(EXE): $(OBJS)
	$(CC) $(CFLAGS) -o $(EXE) $(OBJS) -L$(NETCDF)/lib -lnetcdf -lm

clean:
	rm -f $(OBJS)

%.o: %.c ncensemble.h
	$(CC) $(CFLAGS) -c -I$(NETCDF)/include $<

install: $(EXE)
	cp $(EXE) $(installdir)/
