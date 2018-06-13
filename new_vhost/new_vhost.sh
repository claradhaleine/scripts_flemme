if [ $2 = "create_dir" ] ; then
    echo "Création du directory"
    mkdir /var/www/html/$1

    echo "Attribution et droits"
    chown -R clara:clara /var/www/html/$1
    chmod -R 775 /var/www/html/$1
fi

echo "Configuration du vhost"
cp template.conf /etc/apache2/sites-available/$1.conf
sed -i -e "s/%replace%/$1/g" /etc/apache2/sites-available/$1.conf

echo "Configuration de l'accès SFTP"
cp sftp-config-sample.json /var/www/html/$1/sftp-config.json
sed -i -e "s/%replace%/$1/g" /var/www/html/$1/sftp-config.json

echo "Activation du vhost"
a2ensite $1

echo "Reload de la conf Apache"
systemctl reload apache2.service

if ! grep -q "$1.local" /etc/hosts ; then
    echo "Ajout du domaine dans /etc/hosts"
    echo "127.0.0.1	$1.local" | tee -a /etc/hosts
fi

# cd webperso
# mkdir $1
