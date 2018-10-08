FROM wodby/drupal-php:7.2

USER root

### Setup user for build execution and application runtime
# See https://github.com/GrahamDumpleton/docker-solr/commit/a0592c58947ff2f0c5975099dc3ff9058fe91ef6
ENV BIN_ROOT=/usr/local \
    HOME_WODBY=/home/wodby \
    WODBY_UID="1000" \
    HOME_OPENSHIFT=/home/openshift \
    OPENSHIFT_USER="openshift"

# See
# https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/Dockerfile#L43
# https://github.com/GrahamDumpleton/docker-solr/commit/a0592c58947ff2f0c5975099dc3ff9058fe91ef6
COPY bin/ ${BIN_ROOT}/bin/

# See:
# https://docs.openshift.com/container-platform/3.10/creating_images/guidelines.html
# https://github.com/GrahamDumpleton/docker-solr/commit/a0592c58947ff2f0c5975099dc3ff9058fe91ef6
RUN chmod -R a+x ${BIN_ROOT}/bin/uid_entrypoint; \
    # Chmod the files so we can add openshift user.
    chmod g=u /etc/passwd; \
    chmod g=u /etc/group; \
    # See: https://docs.openshift.com/container-platform/3.10/creating_images/guidelines.html
    # For an image to support running as an arbitray user, directories and files that 
    # may be written to by processes in the image should be owned by the root group and 
    # be read/writable by that group. Files to be executed should also 
    # have group execute permissions.    
    chgrp -R 0 ${APP_ROOT}; \
    chmod -R g=u ${APP_ROOT}; \
    # Change home dirs
    chgrp -R 0 ${HOME_WODBY}; \
    chmod -R g=u ${HOME_WODBY}

### Containers should NOT run as root as a good practice
USER 1000

### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
# See:
# https://docs.openshift.com/container-platform/3.10/creating_images/guidelines.html
# https://github.com/GrahamDumpleton/docker-solr/commit/a0592c58947ff2f0c5975099dc3ff9058fe91ef6
# Swap entrypoint for CMD?
ENTRYPOINT [ "uid_entrypoint" ]
CMD [ "php-fpm" ]