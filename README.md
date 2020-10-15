# Official SimpleRisk Docker images

These images are available on [DockerHub](https://hub.docker.com/u/simplerisk).

Overview of images:
- `simplerisk`: Contains all necessary components to make a SimpleRisk instance work (LAMP stack and mail utilities).
- `simplerisk-minimal`: Only packs components for the SimpleRisk application. You will need to connect it with an external database.

## Build

- Clone the repository (`git clone https://github.com/simplerisk/docker`)
- Run the build command (`docker build -t simplerisk/simplerisk /path/to/dockerfile/directory`)
(Works with Podman)

## Run

To run the container, execute the command:
```
docker run --name simplerisk -d -p 80:80 -p 443:443 simplerisk
```

## Using Docker Compose

A `docker-compose.yml` file is provided for a stack deployment of the application. It will deploy the application with the following components:
- SimpleRisk application (`simplerisk-minimal`)
- MariaDB Database (version 10.3)
- Namshi SMTP Server