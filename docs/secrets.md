# Docker Secrets

## Secrets Used

The application uses several Docker secrets to handle secretive information needed by the different services.

The [docker-compose.yml](../docker-compose.yml) file declares the following secrets:

| Secret | File | Purpose |
| ------ | ---- | ------- |
| accounts_file | [ACCOUNTS](../secrets/ACCOUNTS) | Accounts used by the `auth` service if `AUTH_STRATEGY=local` |
| github_client_id | [GITHUB_CLIENT_ID](../secrets/GITHUB_CLIENT_ID) | GitHub client id used by the `auth` service if `AUTH_STRATEGY=github` |
| github_client_secret | [GITHUB_CLIENT_SECRET](../secrets/GITHUB_CLIENT_SECRET) | GitHub client secret used by `auth` service if `AUTH_STRATEGY=github` |
| cookie_signing | [COOKIE_SIGNING](../secrets/COOKIE_SIGNING) | Used for session cookie signing. Value shall be set to a long GUID |
| jwt_secret | [JWT_SECRET](../secrets/JWT_SECRET) | Used to sign the JWT sent to services behind the gateway. Value shall be set to a long GUID or other password |

More info on authentication can be found in [Authentication Strategies](./deploying-swarm.md#authentication-strategies).

In addition to the secrets above, the [docker-compose.pregen-ssl.yml](../docker-compose.pregen-ssl.yml) file declares
the following secrets:

| Secret | Purpose |
| ------ | ------- |
| cert_file | SSL certificate used by the web server to provide a secure connection |
| cert_key | SSL key used by the web server to provide a secure connection |

**NOTE**: These two secrets are not provided as files in this repository. Instead, they reside in the AWS environment,
and copied into the CircleCI build environment before deploying back to AWS.

If the secrets are not provided, the `openresty` service will create a self-signed certificate which is convenient in
a development environment.

## How Docker Secrets Work

Secrets are specified in a docker-compose or stack file like this:

```yml
secrets:
  first_secret:
    file: ./secrets/FIRST_SECRET
  second_secret:
    file: ./secrets/SECOND_SECRET
```

A service can then reference a secret like this:

```yml
service-example:
  image: example-org/service-example:latest
  secrets:
    - first_secret
  environment:
    FIRST_SECRET_FILE: /run/secrets/first_secret
```

The secret will then be available to the service during runtime under the path `/run/secrets/secret_name`.
A service can only access secrets that it has been given access to in the docker-compose file.
In the example above, `first_secret` would  be available to the service `service-example` but not `second_secret`.

More info on how Docker Swarm handles secrets can be found [here](https://docs.docker.com/engine/swarm/secrets/)
