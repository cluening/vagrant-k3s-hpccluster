FROM centos:8

RUN yum -y install chrony

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
