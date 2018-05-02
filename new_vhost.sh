echo "Création du directory"
mkdir /var/www/html/$1

echo "Attribution et droits"
chmod -R 775 /var/www/html/$1
chown -R www-data:www-data /var/www/html/$1

echo "Copie du template.conf"
cp template.conf /etc/apache2/sites-available/$1.conf

echo "Configuration du vhost"
sed -i -e "s/%replace%/$1/g" /etc/apache2/sites-available/$1.conf

echo "Activation du vhost"
a2ensite $1

echo "Reload de la conf Apache"
systemctl reload apache2.service
