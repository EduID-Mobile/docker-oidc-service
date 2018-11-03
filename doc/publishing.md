## Publishing

build

```
> docker build -t buildtag -t latest [folder with dockerfile]
```

### oidc-provider

publish

```
> docker push eduid/oidc-provider:[gittag]

# form main releases
> docker tag <id> eduid/oidc-provider:latest

```
