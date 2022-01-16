FROM centos:8

RUN yum -y install chrony

RUN yum clean all

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
