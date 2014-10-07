FROM dockerfile/ubuntu

# Install Nginx.
RUN \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y libpcre3-dev libpcrecpp0 libssl-dev zlib1g-dev && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir ~/sources && \
  cd ~/sources && \
  wget http://nginx.org/download/nginx-1.6.2.tar.gz && \
  tar -zxvf nginx-1.6.2.tar.gz && \
  git clone https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng.git && \
  cd nginx-1.6.2 && \
  ./configure \
    --prefix=/etc/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/sbin/nginx \
    --pid-path=/var/log/nginx/nginx.pid \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-http_ssl_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --add-module=/root/sources/nginx-sticky-module-ng && \
  make && \
  make install && \
  rm -rf /etc/nginx/nginx.conf && \
  rm -rf ~/sources

# add nginx config
ADD ./nginx.conf /etc/nginx/nginx.conf 

# Install confd
RUN curl -L https://github.com/kelseyhightower/confd/releases/download/v0.3.0/confd_0.3.0_linux_amd64.tar.gz | tar xz
RUN mv confd /usr/local/bin/confd

# Remove default site
RUN rm -f /etc/nginx/sites-enabled/default && mkdir /etc/nginx/sites-enabled

# Add boot script
ADD ./bin/boot.sh /boot.sh
RUN chmod +x /boot.sh

VOLUME ["/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/etc/confd"]

# Run the boot script
CMD /boot.sh
