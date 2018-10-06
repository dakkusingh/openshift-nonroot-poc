FROM wodby/drupal-php:7.2

USER root

### Setup user for build execution and application runtime
ENV APP_ROOT=/usr/local \
    HOME=/home/wodby \
    WODBY_USER="wodby" \
    WODBY_UID="1000" \
    WODBY_GROUP="root" \
    WODBY_GID="0"    

# See
# https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/Dockerfile#L43
COPY bin/ ${APP_ROOT}/bin/

# See:
# https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/Dockerfile#L44
RUN chmod -R a+x ${APP_ROOT}/bin/uid_entrypoint && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd

# Reset permissions of modified directories and add default user
# RUN adduser -D 1000 -S -s /bin/bash  
RUN adduser -D $WODBY_UID -S -s /bin/bash

	# adduser -u "${WODBY_USER_ID}" -D -S -s /bin/bash -G wodby wodby; \
	# adduser wodby www-data; \  

### Containers should NOT run as root as a good practice
USER 1000

### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
# See:
# https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/bin/uid_entrypoint
# Swap entrypoint for CMD?
ENTRYPOINT [ "uid_entrypoint" ]
CMD [ "php-fpm" ]