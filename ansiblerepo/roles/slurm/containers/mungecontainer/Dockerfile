FROM centos:8

RUN yum -y install munge

RUN yum clean all

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
