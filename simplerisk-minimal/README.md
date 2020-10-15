# SimpleRisk Minimal Image

This image runs SimpleRisk into a 'microservices' approach by using PHP 7.X with Apache as a base container and installing only the application components (no database included). Also has the capability of setting properties of the config.php file through environment variables.

## How to build this image?

Please run the following command according to your container engine:
- **Docker**: `docker build -t simplerisk/simplerisk-minimal .`
- **Podman**: `podman build -t simplerisk/simplerisk-minimal .`

## Ways to run the application

### Set up database

If this is the first time running the application, you need to set up your MySQL/MariaDB database with the SimpleRisk schema. You must provide the environment variable `FIRST_TIME_SETUP` with any value and optionally provide any of the variables that start with `FIRST_TIME_SETUP_*` to customize your configuration.

If you want to only set up the database (and discard the container afterwards), you can simply use `FIRST_TIME_SETUP_ONLY`. This might be helpful in a setup where you can first configure the database (like a initContainer on Kubernetes) and if the process ran successfully, then execute a new container with SimpleRisk running normally.

Another detail to consider is that if you are running the database setup and the `SIMPLERISK_DB_PASSWORD` variable is not provided, the application will generate a random password. You must check the container logs to obtain it.

### Run the application normally

In this case, as long as the `FIRST_TIME_SETUP` variable is not provided, then the application will run normally, considering only the `SIMPLERISK_*` variables.

## Environment variables

### FIRST_TIME_SETUP

Indicates the container to set up the database. It is null by default, and if supplied with any value, it will run the setup (installing the necessary components on the database to make it able to work with the application).

### FIRST_TIME_SETUP_ONLY

When the setup finishes, it will discard the container. It is null by default, and if supplied with any value, it will destroy the container after finishing the setup. 

### FIRST_TIME_SETUP_USER and FIRST_TIME_SETUP_PASS

Credentials for the privileged user that will be used to install the schema on the database. Default value for both is `root`.

### FIRST_TIME_SETUP_WAIT

This is the time, in seconds, the application is going to wait to set up the installation, in case the database is being loaded at the same time. It works together with `FIRST_TIME_SETUP`. Default value is `20`. Helpful in case the database is being deployed at the same time with the application.

### SIMPLERISK_DB_HOSTNAME

This will replace the content of the DB_HOSTNAME property, which is where Simplerisk should look for a database. Default value is `localhost`.

### SIMPLERISK_DB_PORT

This will replace the content of the DB_PORT property, which is where Simplerisk will look for a database port  to connect. Default value is `3306`.

### SIMPLERISK_DB_USERNAME

This will replace the content of the DB_USERNAME property, which is the username to be used to connect to the database. Default value is `simplerisk`.

### SIMPLERISK_DB_PASSWORD

This will replace the content of the DB_PASSWORD property, which is the password to be used to connect to the database. Default value is `simplerisk`.

### SIMPLERISK_DB_DATABASE

This will replace the content of the DB_DATABASE property, which is the name of the database to connect. Default value is `simplerisk`.

### SIMPLERISK_DB_FOR_SESSIONS

This will replace the content of the USE_DATABASE_FOR_SESSIONS property, which if marked as true, will store all sessions on the configured database. Default value is `true`. 

### SIMPLERISK_DB_SSL_CERT_PATH

This will replace the content of the DB_SSL_CERTIFICATE_PATH property, which is the path where the SSL certificates to access the database are located. Default is empty (`''`).