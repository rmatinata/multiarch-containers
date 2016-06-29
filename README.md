# Multiarch containers builds on top of x86

The main goal of this project is to provide scripts that render a multi architecture container build environment, while respecting the following guidelines:

 * Easy to use, preferable be done in one liner
 * Completely automated
 * Easy to tweak and maintain (leverage the update.sh CI pattern)
 * Works across different Linuxes
 * Minimal requirements for deploying

## Installation

There are currently two major ways of deploying and configuring this environment:

 * All-in-one
 * Provision to an existing Linux box

### All-in-one

The all-in-one mode requires that you only have the following, in the deployment node (ie your laptop, or some other machine):

 * Vagrant
 * Some virtual machine technology (or provider, in Vagrant lingo)

The deployment node can be Linux, OS X and possibly Windows (although not tested, so far)

Assuming you meet these requirements, all you have to do is:

```
mkdir <some_location> ; cd <some_location> ; curl -L -O -s https://github.com/rmatinata/multiarch-containers/raw/master/Vagrantfile ; vagrant up
```

... then sit and wait for it to download the box, configure the guest and pull the appropriate example Docker container.

### Provision to an existing Linux box

In case you already have a Linux machine or VM laying around, you can directly run the playbook. For that, you would need ansible to be installed and sudo powers. Just go ahead and:

```
git clone https://github.com/rmatinata/multiarch-containers.git
ansible-playbook ./multiarch-containers/playbook.yml
```

## Applied usage and extension

If everything went well, you should get containers for each supported architecture, that you can work with in an x86 environment. The image tags follow the below pattern:

```
*-multiarch:x86_<arch>
```

... where:
 * * depends on the base image leveraged for each architecture 
 * <arch> is the targe architecture (ie for ppc64le you will get ppc64le/ubuntu-multiarch:x86_ppc64le).

From then on, you can base your Dockerfiles, out of these new base images. For instance, if you are trying to work with s390x containers, you would have something along these lines in your Dockerfile:

```
FROM s390x/ubuntu-multiarch:x86_s390x
...
```

### How to simply run it

If you are interesting in just using one of the pre-built containers, you can do something like:

```
# docker run -it --rm ppc64le/ubuntu-multiarch:x86_ppc64le /bin/bash
root@:/# uname -a
Linux 3.10.0-327.13.1.el7.x86_64 #1 SMP Thu Mar 31 16:04:38 UTC 2016 ppc64le ppc64le ppc64le GNU/Linux
```

