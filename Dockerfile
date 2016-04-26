FROM openshift/weblogic-base-domain:latest
MAINTAINER jwennerb@redhat.com

COPY assets/ /u01/oracle/

USER oracle

EXPOSE 7001 7041

WORKDIR /u01/oracle
CMD ["entrypoint.sh"]
