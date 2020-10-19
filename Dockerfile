FROM ubuntu

# Install basics
RUN apt-get -y update \
&& apt-get -y upgrade\
&& apt-get -y install curl \
&& apt-get -y install sudo \
&& apt-get -y install wget

# Install minio client
RUN cd /tmp \
&& wget --output-document=/usr/local/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc \
&& chmod +rx /usr/local/bin/mc \
&& curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Install S3FS fuse filesystem driver
RUN cd /tmp \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata automake autotools-dev g++ git libcurl4-openssl-dev libfuse-dev libssl-dev libxml2-dev make pkg-config \
&& git clone https://github.com/s3fs-fuse/s3fs-fuse.git \
&& cd s3fs-fuse \
&& ./autogen.sh \
&& ./configure \
&& make \
&& sudo make install

# Install ibmcloud CLI and COS plugin
RUN cd /tmp \
&& apt-get -y install sudo \
&& curl -fsSL https://clis.cloud.ibm.com/install/linux | sh \
&& ibmcloud plugin install cloud-object-storage

COPY split-log.sh /
COPY split-log-with-local-storage.sh /

CMD ["/bin/bash", "-c", "/split-log.sh"]
