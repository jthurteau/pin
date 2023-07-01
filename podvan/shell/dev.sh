if [ -z "$1" ]; then
  echo "MUST specify host build path as first argument";
  exit 1;
fi
cp --update /vagrant/$1/php/php8.cs.php /vagrant/${2:-public}/local-dev.cs.php
cp --update /vagrant/$1/php/php8.lint.php /vagrant/${2:-public}/local-dev.lint.php
cp --update /vagrant/$1/php/info.php /vagrant/${2:-public}/local-dev.info.php
cp -R --update /vagrant/$1/dev/css/ /vagrant/${2:-public}/local-dev.css/
cp -R --update /vagrant/$1/dev/js/ /vagrant/${2:-public}/local-dev.js/