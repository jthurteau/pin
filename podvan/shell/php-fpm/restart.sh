if [ -z "$1" ]; then
  echo "MUST specify application name, e.g. /opt/application/<name> as first argument";
  exit 1;
fi
if [ -z "$2" ]; then
  echo "MUST specify host build path as second argument";
  exit 1;
fi
/vagrant/$2/shell/stop.sh
rc-service nginx restart
/vagrant/$2/shell/php-fpm/start.sh $1