#!/bin/bash
set -e

MYSQL_DATA_DIR="/var/lib/mysql"
mysql_install_db --user=mysql --datadir="$MYSQL_DATA_DIR"
chown -R mysql:mysql "/var/lib/mysql"
# mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"
# mysqld --initialize-insecure=on --user=mysql --datadir="$MYSQL_DATA_DIR"
# mysqld --user=mysql --datadir="$MYSQL_DATA_DIR" --skip-networking &
# pid="$!"

tfile=`mktemp`
if [ ! -f "$tfile" ]
then
    return 1
fi

cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE user='root';
EOF

/usr/sbin/mysqld --user=mysql --bootstrap --verbose=0 < $tfile
rm -f $tfile

ARGV="$@"

## The locale used by some modules like mod_dav
export LANG=C
export APACHE_LOG_DIR="/var/log/apache2"
export APACHE_LOCK_DIR="/tmp"
export APACHE_RUN_DIR="/tmp"
export APACHE_PID_FILE="/tmp/apache2.pid"
export APP_ENVIRONMENT=${APP_ENVIRONMENT}

# the path to your httpd binary, including options if necessary
HTTPD="/usr/sbin/apache2"

# Set this variable to a command that increases the maximum
# number of file descriptors allowed per child process. This is
# critical for configurations that use many file descriptors,
# such as mass vhosting, or a multithreaded server.
# ULIMIT_MAX_FILES="${APACHE_ULIMIT_MAX_FILES:-ulimit -n 8192}"

# Set the maximum number of file descriptors allowed per child process.
# if [ "x$ULIMIT_MAX_FILES" != "x" ] && [ `id -u` -eq 0 ];
# 	then
#     if ! $ULIMIT_MAX_FILES;
# 		then
#         echo "Setting ulimit failed. See README.Debian for more information." >&2
#     fi
# fi

php5enmod json
php5enmod mcrypt
php5enmod mysql

a2enmod expires
a2enmod rewrite
a2enmod headers
a2enmod ssl
a2dismod autoindex
a2dismod status

rm -fr /tmp/apache2.pid
rm -fr /tmp/apache2.lock

/usr/bin/mysqld_safe &

exec "$HTTPD" -d /etc/apache2 -f apache2.conf -e info -D FOREGROUND
