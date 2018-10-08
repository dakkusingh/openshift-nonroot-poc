FROM wodby/drupal-php:7.2

USER root

### Setup user for build execution and application runtime
# See https://github.com/GrahamDumpleton/docker-solr/commit/a0592c58947ff2f0c5975099dc3ff9058fe91ef6
ENV BIN_ROOT=/usr/local \
    HOME=/home/wodby \
    WODBY_USER="wodby" \
    WODBY_UID="1000" \
    WODBY_GID="1000"

# See
# https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/Dockerfile#L43
# https://github.com/GrahamDumpleton/docker-solr/commit/a0592c58947ff2f0c5975099dc3ff9058fe91ef6
COPY bin/ ${BIN_ROOT}/bin/

# See:
# https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/Dockerfile#L44
# https://github.com/GrahamDumpleton/docker-solr/commit/a0592c58947ff2f0c5975099dc3ff9058fe91ef6
RUN chmod -R a+x ${BIN_ROOT}/bin/uid_entrypoint; \
    chgrp -R 0 ${BIN_ROOT}; \
    chmod -R g=u ${BIN_ROOT} /etc/passwd; \
    # Add wodby to root group
    # See: https://docs.openshift.com/enterprise/3.1/creating_images/guidelines.html
    # For an image to support running as an arbitray user, directories and files that 
    # may be written to by processes in the image should be owned by the root group and 
    # be read/writable by that group. Files to be executed should also 
    # have group execute permissions.    
    adduser ${WODBY_USER} root; \
    chgrp -R 0 ${APP_ROOT}; \
    chmod -R g+rw ${APP_ROOT}

### Containers should NOT run as root as a good practice
USER 1000

### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
# See:
# https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/bin/uid_entrypoint
# https://github.com/GrahamDumpleton/docker-solr/commit/a0592c58947ff2f0c5975099dc3ff9058fe91ef6
# Swap entrypoint for CMD?
ENTRYPOINT [ "uid_entrypoint" ]
CMD [ "php-fpm" ]