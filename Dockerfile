FROM ubuntu

RUN cd /tmp \
&& apt-get -y update \
&& apt-get -y upgrade\
&& apt-get -y install curl \
&& apt-get -y install sudo \
&& curl -fsSL https://clis.cloud.ibm.com/install/linux | sh \
&& ibmcloud plugin install cloud-object-storage

COPY split-log.sh /

CMD ["/bin/bash", "-c", "/split-log.sh"]
