# Clone the SimpleRisk Docker Repository
```
git clone https://github.com/simplerisk/docker.git simplerisk-docker
```

# Build the SimpleRisk Docker Image
```
docker build -t simplerisk simplerisk-docker
```

# Start the Docker Container
```
docker run -d -p 80:80 -p 443:443 simplerisk
```

Visit https://localhost/ to test
