# Vagrant and k3s

Everything's better with Kubenetes, right?

This repositry will stand up a simple vagrant-based HPC cluster that can run jobs using k3s, a minimal Kubernetes distribution.

**Warning**: Work in progress. There are definitely some non-best-practices going on here.

## Quickstart

 - Clone this repository
 - desktop: `vagrant up`
 - desktop: `vagrant ssh head`
 - head: `sudo scontrol update nodename=node[01-04] state=resume`
 - desktop: `vagrant ssh fe1`
 - fe1: `salloc -N 4`
 - fe1: `srun -N 4 hostname`


## More details

Take a look at `provision-*.sh` to see what's actually being done.


## Todo

- Replace all of the shell scripts with Ansible
