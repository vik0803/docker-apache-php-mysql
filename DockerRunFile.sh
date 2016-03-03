#!/bin/bash

usage() {
  echo "-----------------------------------------------------------------------"
  echo "                      Available commands                              -"
  echo "-----------------------------------------------------------------------"
  echo -e -n "$BLUE"
  echo "   > build - To build the Docker image"
  echo "   > install - To execute full install at once"
  echo "   > run - To execute full install at once"
  echo "   > reload - To execute full install at once"
  echo "   > stop - To stop container"
  echo "   > start - To start container"
  echo "   > bash - Log you into container"
  echo "   > remove - Remove container"
  echo "   > usage - Display this help"
  echo -e -n "$NORMAL"
  echo "-----------------------------------------------------------------------"
}

if [ -z "$1" ] && [ -z "$2" ]
then
  usage
  exit 1
fi

# Output colors
NORMAL="\\033[0;39m"
RED="\\033[1;31m"
BLUE="\\033[1;34m"

# Names to identify images and containers of this app
IMAGE_NAME='arobasmusic/apache-php-mysql'
CONTAINER_NAME="apache-php-mysql"

# Mounted folders root path
ROOT_PATH="/srv/$CONTAINER_NAME-$2"

APP_ENVIRONMENT=".$2"
# First run variables
VIRTUAL_HOSTS="exemple.com$APP_ENVIRONMENT,exemple2.com$APP_ENVIRONMENT"

MYSQL_ROOT_PASSWORD="mysql"



log() {
  echo "$BLUE > $1 $NORMAL"
}

error() {
  echo ""
  echo "$RED >>> ERROR - $1$NORMAL"
}

build() {
  docker build -t $IMAGE_NAME .

  [ $? != 0 ] && \
    error "Docker image build failed !" && exit 100
}

install() {
  createFolder $ROOT_PATH
  createFolder "$ROOT_PATH/conf/apache2/sites-enabled"
  createFolder "$ROOT_PATH/conf/php5/conf.d"
  createFolder "$ROOT_PATH/conf/mysql/"
  createFolder "$ROOT_PATH/html"
  createFolder "$ROOT_PATH/logs/apache2"
  createFolder "$ROOT_PATH/logs/php5"
  loadConfFiles
}

createFolder() {
  if [ ! -d "$1" ]
  then
    mkdir -p $1
  fi
}

loadConfFiles() {
  cp conf/sites-enabled.conf "$ROOT_PATH/conf/apache2/sites-enabled/"
  cp conf/php.ini "$ROOT_PATH/conf/php5/"
  cp conf/my.cnf "$ROOT_PATH/conf/mysql/"
}

run() {
  log "First run of Docker container $CONTAINER_NAME"
  docker run --name="$CONTAINER_NAME-$1" -d -e VIRTUAL_HOST=$VIRTUAL_HOSTS -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -e APP_ENVIRONMENT=$APP_ENVIRONMENT -v $ROOT_PATH/html:/var/www/html -v $ROOT_PATH/logs/apache2:/var/log/apache2 -v $ROOT_PATH/logs/php5:/var/log/php5 -v $ROOT_PATH/mysql:/var/lib/mysql  -v $ROOT_PATH/conf/apache2/sites-enabled:/etc/apache2/sites-enabled -v $ROOT_PATH/conf/php5:/etc/php5/apache2 -v $ROOT_PATH/conf/php5:/etc/php5/cli -v $ROOT_PATH/conf/mysql:/etc/mysql $IMAGE_NAME
  [ $? != 0 ] && error "First run failed !" && exit 101
}

bash() {
  log "BASH"
  docker exec -it "$CONTAINER_NAME-$1" /bin/bash
}

stop() {
  docker stop "$CONTAINER_NAME-$1"
}

start() {
  docker start "$CONTAINER_NAME-$1"
}

reload() {
  log "Reload of Docker container $CONTAINER_NAME-$1"
  stop
  remove
  loadConfFiles $1
  run $1
}

remove() {
  log "Removing previous container $CONTAINER_NAME" && \
      docker rm -f "$CONTAINER_NAME-$1" &> /dev/null || true
}

$*
