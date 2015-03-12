#
# Nginx Dockerfile
#

# Pull base image
FROM ubuntu:14.04

# User limits
RUN sed -i.bak '/\# End of file/ i\\# Following 4 lines added by docker-couchbase-server' /etc/security/limits.conf
RUN sed -i.bak '/\# End of file/ i\\*                hard    memlock          unlimited' /etc/security/limits.conf
RUN sed -i.bak '/\# End of file/ i\\*                soft    memlock         unlimited\n' /etc/security/limits.conf
RUN sed -i.bak '/\# End of file/ i\\*                hard    nofile          65536' /etc/security/limits.conf
RUN sed -i.bak '/\# End of file/ i\\*                soft    nofile          65536\n' /etc/security/limits.conf
RUN sed -i.bak '/\# end of pam-auth-update config/ i\\# Following line was added by docker-couchbase-server' /etc/pam.d/common-session
RUN sed -i.bak '/\# end of pam-auth-update config/ i\session	required        pam_limits.so\n' /etc/pam.d/common-session

# Locale
RUN locale-gen en_US en_US.UTF-8

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install vim wget curl bridge-utils && \
  wget 'http://nginx.org/download/nginx-1.7.7.tar.gz' && \
  tar -xzvf nginx-1.7.7.tar.gz && \
  cd nginx-1.7.7/ && \
  ./configure --prefix=/opt/nginx --add-module=/path/to/headers-more-nginx-module && \
  make && \
  make install && \
  cd /usr/local/bin && \
  curl -L https://github.com/kelseyhightower/confd/releases/download/v0.6.3/confd-0.6.3-linux-amd64 -o confd && \
  chmod +x confd && \
  mkdir -p /etc/confd/conf.d && \
  mkdir -p /etc/confd/templates

RUN rm -f /etc/nginx/sites-enabled/default
RUN rm -r /etc/nginx/nginx.conf

ADD nginx.toml /etc/confd/conf.d/nginx.toml
ADD nginx.tmpl /etc/confd/templates/nginx.tmpl
ADD nginx.conf /etc/nginx/nginx.conf
ADD confd-watch /usr/local/bin/confd-watch
RUN chmod 755 /usr/local/bin/confd-watch



# Expose port
EXPOSE 80

# start couchbase
CMD ["/bin/bash"]
