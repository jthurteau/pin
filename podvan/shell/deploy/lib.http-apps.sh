mkdir -p /var/www/application
mkdir -p /opt/application/vendor
ln -s /opt/application/$1 /var/www/application/$1
if [ -n "$3" ]; then
    ln -s /var/www/application/$1/$2 /var/www/html/$3; else
    rmdir /var/www/html;
    if [ -z "$2" ]; then 
    ln -s /var/www/application/$1 /var/www/html; else
    ln -s /var/www/application/$1/$2 /var/www/html;
    fi
fi
