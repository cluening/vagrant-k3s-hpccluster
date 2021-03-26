# Vagrant and k3s

## Quickstart

 - Clone this repository
 - desktop: `vagrant up`
 - desktop: `vagrant ssh head`
 - head: `sudo scontrol update nodename=node[01-04] state=resume`
 - desktop: `vagrant ssh fe1`
 - fe1: `salloc -N 4`
 - fe1: `srun -N 4 hostname`
