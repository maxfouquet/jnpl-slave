FROM openjdk:8-slim
LABEL maintainer="Max Fouquet <fouquet.max@gmail.com>"

# Those are allowed to be changed at build time
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG git_lfs_version=2.9.1

ENV JENKINS_HOME=/var/jenkins_home \
    JENKINS_USER=${user} \ 
    SONAR_SCANNER_VERSION=3.2.0.1227

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget unzip curl dumb-init git libltdl7 openssh-client procps \
    && rm -rf /var/lib/apt/lists/* \
    \
    # Install git LFS
    && curl -#LSo git-lfs.deb https://packagecloud.io/github/git-lfs/packages/debian/stretch/git-lfs_${git_lfs_version}_amd64.deb/download.deb \
    && dpkg -i git-lfs.deb \
    && rm -f git-lfs.deb \
    \
    # Install sonarqube
    && wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip \
    && unzip sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip \
    && mv sonar-scanner-$SONAR_SCANNER_VERSION-linux /opt/sonar \
    && chmod u+x -R /opt/sonar/bin \
    && rm sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip \
    \
    # Jenkins is run with user `jenkins`, uid = 1000
    # If you bind mount a volume from the host or a data container,
    # ensure you use the same uid
    && groupadd -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user} \
    \
    # Tweak global SSH client configuration
    && sed -i '/^Host \*/a \ \ \ \ ServerAliveInterval 30' /etc/ssh/ssh_config \
    && sed -i '/^Host \*/a \ \ \ \ StrictHostKeyChecking no' /etc/ssh/ssh_config \
    && sed -i '/^Host \*/a \ \ \ \ UserKnownHostsFile /dev/null' /etc/ssh/ssh_config

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

COPY jenkins-slave /usr/local/bin/jenkins-slave

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/jenkins-slave"]