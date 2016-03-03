FROM ubuntu:14.04
MAINTAINER Jérémy Jousse <jeremy.jousse@arobas-music.com>

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-client php5 libapache2-mod-php5 php5-json php5-mcrypt php5-mysql php5-curl php5-gd
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apache2

ADD apache2.conf /etc/apache2/apache2.conf

ADD docker-entrypoint.sh /entrypoint.sh


# Configure container
VOLUME /var/www/html
VOLUME /var/lib/mysql
VOLUME /var/log/apache2
VOLUME /var/log/php5
VOLUME /etc/apache2/sites-enabled/
VOLUME /etc/php5/apache2
VOLUME /etc/php5/cli
VOLUME /etc/mysql

COPY docker-entrypoint.sh /usr/local/bin/

EXPOSE 8080

CMD ["docker-entrypoint.sh"]
