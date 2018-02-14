_PATH=/var/www/public/parelli_ror/

# build environments test, staging, production
_ENV=test
# default set to develop site
_DOMAIN=parellidev.epicbusinessapps.com

case $_ENV in
  test) 
    $_DOMAIN=parellidev.epicbusinessapps.com
    ;;
  staging)
    $_DOMAIN=parellistaging.epicbusinessapps.com
    ;;
  production)
    $_DOMAIN=parelli.epicbusinessapps.com
    ;;
esac

sudo mv $_PATH/codedeploy/$_DOMAIN /etc/nginx/sites-available/$_DOMAIN
sudo ln -s /etc/nginx/sites-available/$_DOMAIN /etc/nginx/sites-enabled --force

sudo cp /home/ubuntu/secrets.yml $_PATH/config/

cd $_PATH
bundle install
RAILS_ENV=$_ENV rake db:migrate
RAILS_ENV=$_ENV rake assets:precompile

sudo service nginx restart

exit 0