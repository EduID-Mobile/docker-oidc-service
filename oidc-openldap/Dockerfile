FROM alpine

## install the latest openldap tools

RUN apk add --no-cache openldap openldap-backend-all openldap-overlay-all openldap-clients openldap-passwd-pbkdf2 bash && \
    mkdir -p /install /run/openldap /var/lib/openldap/openldap-data /etc/openldap/slapd.d && \
    chown -R ldap:ldap /run/openldap /var/lib/openldap/openldap-data /etc/openldap/slapd.d

ADD schema /install/schema
ADD slapd.conf.default /etc/openldap/slapd.conf
ADD entrypoint.sh /install/
ADD directory.root.ldif /install/

RUN chmod 755 /install/entrypoint.sh

# RUN /usr/sbin/slapd -d 64 -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d/

## NOTE TO SELF
# need to setup an admin account for the cn=config space (see http://www.zytrax.com/books/ldap/ch6/slapd-config.html)
# THEN remove the initial database and install the new database for the correct directory

# Generic Schema

## This works only AFTER the initial configuration took place.

RUN slapadd -n 0 -l  /install/schema/cosine.ldif -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d/ &&\
 slapadd -n 0 -l  /install/schema/corba.ldif && \
 slapadd -n 0 -l  /install/schema/nis.ldif && \
 slapadd -n 0 -l  /install/schema/inetorgperson.ldif && \
 slapadd -n 0 -l  /install/schema/ppolicy.ldif && \
# EduID Schema
 slapadd -n 0 -l  /install/schema/eduperson-201602.openldap.ldif && \
 slapadd -n 0 -l  /install/schema/swissedu-201706.openldap.ldif && \
# OAuth2 Schema
 slapadd -n 0 -l /install/schema/oidc-client.openldap.ldif && \
 slapadd -n 0 -l  /install/schema/oidc-session.openldap.ldif && \
 slapadd -n 0 -l  /install/schema/oidc-token.openldap.ldif

# Install the basic directory structure.
RUN slapadd -n 1 -l /install/directory.root.ldif

EXPOSE 389 636

VOLUME ["/var/lib/openldap/openldap-data"]

ENTRYPOINT ["/install/entrypoint.sh"]
# CMD ["sh"]
