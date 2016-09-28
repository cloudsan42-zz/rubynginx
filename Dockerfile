FROM debian:jessie

MAINTAINER NGINX Docker Maintainers "docker-maint@nginx.com"

ENV NGINX_VERSION 1.11.4-1~jessie


RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
        && apt-get install wget -y \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
						ca-certificates \
						nginx=${NGINX_VERSION} \
						nginx-module-xslt \
						nginx-module-geoip \
						nginx-module-image-filter \
						nginx-module-perl \
						nginx-module-njs \
						gettext-base \
	&& rm -rf /var/lib/apt/lists/*

# Dependencies for ruby 
RUN  apt-get update && apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev -y

# Install Ruby 2.2.5
RUN wget http://ftp.ruby-lang.org/pub/ruby/2.2/ruby-2.2.5.tar.gz && tar -xzvf ruby-2.2.5.tar.gz && cd ruby-2.2.5/ && ./configure && make && make install 
#Install gems 
RUN gem install --no-rdoc --no-ri --version 3.6.0 puma && gem install --no-rdoc --no-ri --version 1.6.4 rack


#Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log
#Copying certs 
COPY default.conf /etc/nginx/conf.d/
COPY server.crt /etc/ssl/certs/
COPY server.key /etc/ssl/private/

#Copying ruby app files  and script to start nginx
COPY ./stack_* /usr/local/bin/

#Expose ports 

EXPOSE 443

CMD /usr/local/bin/stack_nginx /usr/local/bin/stack_healthcheck sleep 86400

