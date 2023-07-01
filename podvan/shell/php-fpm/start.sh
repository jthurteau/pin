if [ -z "$1" ]; then
  echo "MUST specify application name, e.g. /opt/application/<name> as first argument";
  exit 1;
fi
podman run -d -p 8090:9000 --mount type=bind,src=/vagrant,dst=/opt/application/$1,ro=true --mount type=bind,src=/opt/project,dst=/opt/project  --mount type=bind,src=/opt/application/vendor,dst=/opt/application/vendor,ro=true php-fpm