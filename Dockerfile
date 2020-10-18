FROM ubuntu

RUN cd /tmp \
&& apt-get -y update \
&& apt-get -y upgrade\
&& apt-get -y install curl \
&& apt-get -y install sudo \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata automake autotools-dev g++ git libcurl4-openssl-dev libfuse-dev libssl-dev libxml2-dev make pkg-config \
&& git clone https://github.com/s3fs-fuse/s3fs-fuse.git \
&& cd s3fs-fuse \
&& ./autogen.sh \
&& ./configure \
&& make \
&& sudo make install \
&& cd .. \
&& curl -fsSL https://clis.cloud.ibm.com/install/linux | sh \
&& ibmcloud plugin install cloud-object-storage

COPY split-log.sh /

CMD ["/bin/bash", "-c", "/split-log.sh"]
