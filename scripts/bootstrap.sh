#!/bin/sh

cp /etc/hosts.base /etc/hosts

# Lee su propio hostname de la metadata que se le da a la instancia al crearla
HOSTNAME=`/usr/bin/ec2metadata --user-data | /usr/bin/awk '-F=' '$1 == "hostname" {print $2}'`

if [ -n $HOSTNAME ]; then
  echo "127.0.0.1 $HOSTNAME" >> /etc/hosts

  echo $HOSTNAME > /etc/hostname
  /bin/hostname $HOSTNAME
fi

# Actualiza el /etc/hosts con los servidores que están correindo.
/root/scripts/ec2-hosts.rb

# Actualiza el código de la aplicación
su -m otlive -c "cd /var/www/otlive; git pull origin otlive_production"

# Antes de arrancar el webserver tiene que actualizar el contendio!
/etc/init.d/nginx start

