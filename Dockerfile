# Download base image ubuntu 20.04
FROM ubuntu:20.04

# LABEL about the custom image
LABEL maintainer="gcarter@openaprs.net"
LABEL version="0.1"
LABEL description="Docker image for OpenAPRS system."

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

ADD ./buildworld.sh /root/buildworld.sh

# Update Ubuntu Software repository
RUN apt-get update

# Install nginx, php-fpm and supervisord from ubuntu repository
RUN apt-get install -y nginx php-fpm supervisor git automake autotools-dev autoconf libtool libc-bin libc6 libc6-dev libcxxtools-dev libossp-uuid-dev libreadline-dev libc++-dev binutils gcc g++ \
                       zlib1g zlib1g-dev libpthread-stubs0-dev make pkg-config libmemcached-dev memcached mysql-server mysql-client libmysqlclient-dev libmysql++ mosquitto mosquitto-clients \
                       cmake cmake-gui cmake-curses-gui libssl-dev logrotate cron php-pear php-dev php-rrd && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

RUN \
    cd /root && \
    git clone https://github.com/omnidynmc/stomprrd.git

# Define the ENV variable
ENV nginx_vhost /etc/nginx/sites-available/default
ENV php_conf /etc/php/7.4/fpm/php.ini
ENV nginx_conf /etc/nginx/nginx.conf
ENV supervisor_conf /etc/supervisor/supervisord.conf

# Enable PHP-fpm on nginx virtualhost configuration
COPY default ${nginx_vhost}
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf} && \
    echo "\ndaemon off;" >> ${nginx_conf}
    
# Copy supervisor configuration
COPY supervisord.conf ${supervisor_conf}

# Copy crontab configuration
COPY config/crontab/cron.daily /etc/cron.daily

# Copy logrotate configuration
COPY config/logrotate/logrotate.d /etc/logrotate.d

RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php
    
# Volume configuration
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Copy start.sh script and define default command for the container
COPY start.sh /start.sh
CMD ["./start.sh"]

# Expose Port for the Application 
EXPOSE 80 443
