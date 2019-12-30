## Jenkins auto slave

A docker image of Jenkins `JNLP` based agent. This image can self-register to Jenkins master, it will also unregister from the master when container exits. Another cool feature is that this image doesn't have `agent.jar` pre installed, instead it downloads it from Jenkins master when the container starts. This approach will help to avoid versioning problems that might happen between `master` and `slave`.

***

**Environment variables**

most used variables:

- `JENKINS_AUTH` jenkins server username and either password or API token (in `user:secret` format)
- `JENKINS_URL` jenkins master url (example `http://localhost:8080`)
- `JENKINS_SLAVE_LABEL` space delimited labels, used to group agents into one logical group (no default)
- `JENKINS_SLAVE_MODE` how Jenkins schedules builds on this node, `NORMAL/EXCLUSIVE` (default is `NORMAL`)
- `JENKINS_SLAVE_NAME` the name which will be used when registering (default is `$HOSTNAME`)
- `JENKINS_SLAVE_NUM_EXECUTORS` number of executors to use (defaults to `1`)

less used and can keep the defaults

- `DOCKER_GROUP` the docker group name, should be same as the docker's host group (defaults to `docker`)
- `DOCKER_SOCKET` the docker socket location (default is `/var/run/docker.sock`)
- `JAVA_OPTS` pass java options to the `slave.jar` process (default is not set)

***

**Required permissions**

The image should be used in trusted environment, even so the permissions for the user that will be used to register the slaves should be restricted.

> **DO NOT USE ADMIN USER**

Therefore, in order to be able to self register to the master, a user with relevant permissions must be created.

The required permissions are:

- `Overall/Read`
- `Agent/Connect`
- `Agent/Create`
- `Agent/Delete`

***

**Running**

```sh
$ docker run -d \
    --net host \
    -e JENKINS_URL=http://jenkins.internal.domain:8080 \
    -e JENKINS_AUTH=registrator:1234567890123456789012  \
    -v /path/to:/var/jenkins_home \
    maxfouquet/jnpl-slave
```

***