# Docker secrets

## How docker secrets work.

This use case uses docker secrets to handle secretive information needed by the different services running in the swarm.

The files used to populate our secrets can be found under `/secrets` with one file per secret.

These are added to the docker-compose like this 
```secrets:
  first_secret:
    file: ./secrets/FIRST_SECRET
  second_secret:
    file: ./secrets/SECOND_SECRET
```

A service can then reference a secret like this 

```
  ...
  service-example:
    image: example-org/service-example:latest
    secrets:
      - first_secret
    environment:
      FIRST_SECRET_FILE: /run/secrets/first_secret
  ...
```
The secret will then be available to the service during runtime under the path `/run/secrets/secret_name`. The service will only get access to the secrets that it's given access to in the docker-compose and not all the defined secrets. IE `first_secret` would  be available for the service `service-example` but not `second_secret`

More info on how docker swarm handles secrets can be found [here](https://docs.docker.com/engine/swarm/secrets/)

## Secrets we are using

We are using the secrets `acounts_file` to load the authenticated accounts to the auth service if it is started with the environment variable `AUTH_STRATEGY` set to `local`. Otherwise the auth service uses the secrets `github_client_id` and `github_client_secret` to provice its authentication to github.

If you are using the github auth method you will have to populate the `GITHUB_CLIENT_ID` and the `GITHUB_CLIENT_SECRET` files with your own client id and client secret to authenticate your service to github.

The secrets `cert-gateway.crt` and `cert-gateway.key` are the ssl certificate and key used by the webserver to provide a secure connection.

The secret `cookie_signing` is used to sign the session cookie and the value in the `COOKIE_SIGNING` file should be changed to a long GUID.

The secret `JWT_SECRET` are used to sign the JWT sent to the services behind the gateway and the value in the `JWT_SECRET` file should be changed to a long GUID or other password.




