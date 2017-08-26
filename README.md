# DockerDeploy

Provides straightforward framework for deploying containers as services

## Usage

#### Install

From Git
``` bash
$ git clone https://github.com/jharshman/DockerDeploy.git /opt/DockerDeploy
$ cd /opt/DockerDeploy
$ ./bin/install.sh
```

#### Add a new application

1. Add application docker-compose file to `apps/`
2. Add service or upstart template to `init/`

#### Update an application 

``` bash
$ update-tag.sh <service> <version>
```

## Author

Joshua Harshman [joshua@joshuaharshman.com](mailto:joshua@joshuaharshman.com)
