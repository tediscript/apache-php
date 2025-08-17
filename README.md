# Apache - PHP Docker Image for WordPress

## Preventing WordPress Auto-Generation in Container

If you want to prevent the container from auto-generating a fresh WordPress installation, create the following empty files in your `/var/www/html` directory (either on your host if bind mounting, or inside the container):


### Using absolute path (inside container or absolute host path):
```
mkdir -p /var/www/html/wp-includes
touch /var/www/html/index.php /var/www/html/wp-includes/version.php /var/www/html/wp-config.php
```

### Using relative path (inside your html directory for bind mount):
```
cd html
mkdir -p wp-includes
touch index.php wp-includes/version.php wp-config.php
```

This will ensure the entrypoint script does not copy WordPress files or auto-generate a config file.

## WordPress: 
    - tag: tediscript/apache-php:7.4-wordpress
    - tag: tediscript/apache-php:8.2-wordpress
    - tag: tediscript/apache-php:8.3-wordpress
    - reference: https://make.wordpress.org/hosting/handbook/server-environment/


## Github repo for this image: https://github.com/tediscript/apache-php
