if [ -z "$1" ]; then
  echo "MUST specify host build path as first argument";
  exit 1;
fi
cp /vagrant/$1/nginx/conf /etc/nginx/http.d/default.conf
#cp /vagrant/$1/nginx/backend /etc/nginx/extra/backend.conf
rc-service nginx restart