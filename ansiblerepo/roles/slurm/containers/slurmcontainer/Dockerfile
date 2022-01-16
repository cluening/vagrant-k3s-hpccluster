FROM centos:8

RUN yum -y install http://repos.openhpc.community/OpenHPC/2/CentOS_8/x86_64/ohpc-release-2-1.el8.x86_64.rpm

RUN yum -y install slurm-slurmctld-ohpc sssd-common

RUN yum clean all

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
