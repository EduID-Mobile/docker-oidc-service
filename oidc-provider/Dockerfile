# use the slim line alpine rather than LTS carbon
FROM node:alpine as builder

RUN apk add --no-cache --virtual buildtools make gcc g++ python linux-headers paxctl gnupg git

# Create the app directory
WORKDIR /oidc-provider

# the oidc provider expects all configurations in /etc/oidc/*
# the standalone version may override this configuration, which is not the
# case for docker containers.

# load dependencies for production only

RUN chown -R node /oidc-provider
USER node
RUN npm install eduid-mobile/ldap-oidc-provider#v3 --prefix /oidc-provider --global --production

FROM node:alpine

ENV NODE_PATH /oidc-provider
ENV PATH /oidc-provider/bin:$PATH

# create configuration directory
RUN mkdir -p /etc/oidc /template

# Create the app directory
WORKDIR /oidc-provider

# get the node modules
COPY --from=builder /oidc-provider .

# copy the templates into the volume
RUN chown -R node /etc/oidc /template /oidc-provider
USER node

# the internal default port
# NOTE: the exposed port MUST be linked to a SSL termination!
EXPOSE 3000

# Before we launch we expose the volumes
VOLUME ["/template"]

# launch our app
ENTRYPOINT ["oidcd", "-v"]
# CMD ["oidcd", "-v"]
