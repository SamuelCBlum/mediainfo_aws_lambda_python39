# PURPOSE: This Dockerfile will prepare an Amazon Linux docker image with everything needed to compile binary MediaInfo libraries for Python 3.9
# USAGE: 
# 1. Build the docker image:
#     docker build --tag=pymediainfo-layer-factory:latest .
# 2. Build and copy MediaInfo libraries to ./pymediainfo-python[39].zip
#     docker run --rm -it -v $(pwd):/data pymediainfo-layer-factory cp /packages/pymediainfo-python39.zip /data

FROM amazonlinux

WORKDIR /
RUN yum update -y

# Install Python 3.9
RUN yum -y install openssl-devel bzip2-devel libffi-devel wget tar gzip make gcc-c++
RUN yum -y install zip unzip
RUN wget https://www.python.org/ftp/python/3.9.7/Python-3.9.7.tgz
RUN tar -xzvf Python-3.9.7.tgz
WORKDIR /Python-3.9.7
RUN ./configure --enable-optimizations
RUN make install

# Install Python packages
RUN mkdir /packages
RUN echo "pymediainfo" >> /packages/requirements.txt
RUN echo "zipp" >> /packages/requirements.txt
RUN echo "typing-extensions" >> /packages/requirements.txt
RUN echo "importlib-metadata" >> /packages/requirements.txt

RUN mkdir -p /packages/pymediainfo-3.9/python/lib/python3.9/site-packages
RUN pip3.9 install -r /packages/requirements.txt -t /packages/pymediainfo-3.9/python/lib/python3.9/site-packages

# Download MediaInfo
WORKDIR /root
RUN wget https://mediaarea.net/download/binary/libmediainfo0/22.03/MediaInfo_DLL_22.03_Lambda_x86_64.zip
RUN unzip MediaInfo_DLL_22.03_Lambda_x86_64.zip

# Create zip files for Lambda Layer deployment
RUN cp /root/lib/* /packages/pymediainfo-3.9/python
RUN cp /root/lib/* /packages/pymediainfo-3.9/
WORKDIR /packages/pymediainfo-3.9/
RUN zip -r9 /packages/pymediainfo-python39.zip .
WORKDIR /packages/
RUN rm -rf /packages/pymediainfo-3.9/
