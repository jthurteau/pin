#!/bin/sh
#TODO make sure SOME version of php is available...
if [ -n "$1" ]; then cd $1; fi
# from https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet --install-dir=/bin --filename=composer
RESULT=$?
rm composer-setup.php
exit $RESULT