# https://hub.docker.com/_/php
if [ -z "$1" ]; then
  echo "MUST specify application name, e.g. /opt/application/<name> as first argument";
  exit 1;
fi
if [ -z "$2" ]; then
  echo "MUST specify host build path as second argument";
  exit 1;
fi
if [ ! -d "/vagrant/$2" ]; then
    echo "public folder /vagrant/$2 does not exist in pod host!"; exit 1;
fi
echo building $1
podman build -t php-fpm /vagrant/$2 --build-arg PRIMARY_APPLICATION=$1 && /vagrant/$2/shell/php-fpm/start.sh $1 $2