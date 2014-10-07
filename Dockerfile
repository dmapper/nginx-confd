FROM dockerfile/ubuntu

# Install Nginx.
RUN \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# Install confd
RUN curl -L https://github.com/kelseyhightower/confd/releases/download/v0.3.0/confd_0.3.0_linux_amd64.tar.gz | tar xz
RUN mv confd /usr/local/bin/confd

# Remove default site
RUN rm -f /etc/nginx/sites-enabled/default

# Add boot script
ADD ./bin/boot.sh /boot.sh
RUN chmod +x /boot.sh

VOLUME ["/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/etc/confd"]

# Run the boot script
CMD /boot.sh
