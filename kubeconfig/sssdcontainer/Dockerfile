FROM centos:8

RUN yum -y install sssd-client sssd-common

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
