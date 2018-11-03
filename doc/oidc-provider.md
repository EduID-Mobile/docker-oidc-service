## OIDC Provider configuration

### Install
Note all commands are UNIX only. I tested them on my mac and linux boxes.
They are not available on windows machines or must get invoked differently

Make shure that node-jose-tools are installed on your system.

```
> npm i -g node-jose-tools
```

download the latest image

```
> docker pull eduid/oidc-provider
```

### Configure

Step 1: Build your Keychains

Step 2: Configure the data sources

Step 3: Configure the basic systems

Step 4: Customize the UI templates

### Build Keychains

OIDC provider requires two keychains

Build certificates with node-jose-tools

Certificates are the keys the clients use to validate the responses from your IDP.

```
> jose newkey -t rsa -s 2048 -u sig | jose addkey -j certificates.jwks -C -U
> jose newkey -t rsa -s 4096 -u enc | jose addkey -j certificates.jwks -U
```

Create the integrity key keychain (this is for internal use, only)

```
> jose newkey -t oct -s 512 -u sig -a HS512 | jose addkey -j integrity.jwk -C -U
```

Create a pairwiseSalt file, if you want to use OIDC sector identifiers:

```
> head -c 50 /dev/random | shasum | awk '{ print $1 }' > pairwisesalt
```

NOTE: This has changed with the latest node-oidc-provider and will be replaced soon.

### Configure the data sources

__tl/dr__

 * Create a configuration that configures the connections to your different data sources.

 * You need to create one name configuration entry for each data source you want to use.

 * Because most connections require a password, you should store this configuration as a docker secret.

__Long explenation__

OIDC provider can use different data sources for the different kinds of data used by the service. This is important for persistent data. I.e. if you want your authorizations to make it across a system restart, then you are interested in data persistence.

OIDC provider uses structures to access and manipulate the actual data. These structures are called adapters. The adapters connect a data source to the service and deal with the specialities of these data sources.

OIDC provider has the following adapters:

 * AccessToken
 * Account
 * AuthorizationCode
 * Client
 * ClientCredentials
 * InitialAccessToken
 * Interaction
 * ProxyClient
 * RefreshToken
 * RegistrationAccessToken
 * Session

Each adapter can store its data in a different data source. OIDC Provider supports the following types of data sources for its adapters:

 * ```ldap``` directories
 * ```memory``` hashes
 * ```mongodb``` databases
 * ```redis``` databases
 * (```sql``` databases)

OIDC provider allows you to use different data sources for the different adapters. I.e., you can use different LDAP directories for your accounts and your clients, or use different redis databases for the different tokens.

Because most data sources are password protected, OIDC provider allows you to separate the connection configuration from the main configuration. However, you are free to configure the connections in the main configuration file.

The basic configuration format is a following:

```
{
    "CONNECTION_NAME": {
        "type": "CONNECTION_TYPE",
        "url": "CONNECTION_URL"
        "username": "CONNECTION_USERNAME",
        "password": "CONNECTION_PASSWORD",
        "database": "CONNECTION_DATABASE"
    }
}   
```

The ```CONNECTION_NAME``` is for your free choice. The name is later used for configuring the data source of the adapters.

The ```CONNECTION_TYPE``` is either one of ```ldap```, ```redis```, ```mongodb```, ```sql```, or ```memory```.

The CONNECTION_URL is the reference to the service name of the data source.

LDAP data sources use ```bind``` instead of ```username```. LDAP ignores the ```database``` configuration.

redis data sources that are unsecured, require only a ```CONNECTION_URL```.

For redis data sources you should configure the database number into
the connection url instead of defining a ```database``` name.

### Configure the basic systems

The basic configuration consists of defining the service URLs and connecting the adapters to the connections.

The most basic configuration for a service relying only on redis data source:

```
{
    "connections": {
        "redis": {
        "type": "redis",
        "url": "redis://redis-serviceurl/2"
        }
    }
    "urls": {
        "issuer": "your service url",
        "interaction": "interaction url for user interactions",
        "homepage": "the homepage of your service"
    },
    "adapters": {
      "Session": {
        "source": "redis"
      },
      "AccessToken": {
        "source": "redis"
      },
      "AuthorizationCode": {
        "source": "redis"
      },
      "RefreshToken": {
        "source": "redis"
      },
      "InitialAccessToken": {
        "source": "redis"
      },
      "RegistrationAccessToken": {
        "source": "redis"
      },
      "ClientCredentials": {
        "source": "redis"
      },
      "Client": {
        "source": "redis"
      },
      "ProxyClient": {
        "source": "redis"
      },
      "Account": {
        "source": "redis"
      },
      "Interaction": {
        "comment": "normally this is in memory only",
        "source": "redis"
      }
    }
}
```

The urls in the ```urls```-section are the __public__ URLs of your service. You will certainly run the OIDC provider behind a ssl termination proxy. In this case, you need to configure the URLs here to match the configuration of your proxy.

The ```source``` key holds the ```CONNECTION_NAME``` of one data source from the connections configuration.

Adapters using LDAP data sources are require additional configuration:

```
{
    ...

    "ClientCredentials": {
      "source": "ldapdirectory",
      "id": "oauthClientID",
      "base": "ou=federation,dc=eduid,dc=ch",
      "mapping": "/etc/oidc/client-mapping.json"
    },

    ...
}
```

The ```id``` key points to the identifying field for the record. The value must point to an attribute that has unique values in your directory.

The ```base``` key contains a reference to the branch of the directory under which the relevant entries are stored. This value is used as the root for all related searchs.

The ```mapping``` key contains the mapping from LDAP attributes into the internal data structure of the adapter. The mapping must match the attribute structure of your LDAP entries.

### Customize the UI Templates

node-oidc-provider uses a simple templating system for user authorization.

These templates are exposed in the /template volume.

You can replace the templates in the template volume to match your local needs.

You need to have at least the following templates

 * ```_layout.html```
 * ```interaction.html```
 * ```login.html```

CSS and Javascript files are best located on an external source, such as a CDN.

Important: Complex logic, such as user registration needs to be placed into a separate subsystem

### Default Values
