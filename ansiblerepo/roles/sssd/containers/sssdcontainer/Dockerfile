FROM centos:8

RUN yum -y install sssd-client sssd-common

RUN yum clean all

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
