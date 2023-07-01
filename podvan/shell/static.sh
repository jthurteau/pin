if [ -z "$1" ]; then
  echo "MUST specify static file to link as first argument";
  exit 1;
fi
ln -s /vagrant/${2:-public}/local-dev.css /var/www/localhost/htdocs/$1