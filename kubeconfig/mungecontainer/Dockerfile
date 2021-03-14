FROM centos:8

RUN yum -y install munge

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
