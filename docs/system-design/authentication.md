# Authentication

The authentication implementation aims to solve interactive login scenarios. Accessing services programmatically
requires a different mean of authorization (e.g. by the use of API-keys). The proposed solution is flexible enough to
allow future support for API-keys if needed.

GitHub is used as identity provider, but could easily be replaced by any OAuth2 compatible identity provider.

To handle login/logout, the concept of a _session_ is used. Sessions are maintained in the Session Database and the
session identifier is set in a client-side session cookie.

Backend services utilize JWTs (which are stateless and cannot be revoked), and are associated with login sessions
(which by definition represents a state). The JWTs are stored in the Session Database. JWTs are _not_ sent to the
client. If a JWT is leaked into client space, there is no way of revoking the JWT (i.e. not possible to logout).

Logout is done by removing the session from the Session Database.

## Collaborating Components

#### Web Browser

- Provides a "sign in" option for the user opening the Qliktive Assisted Prescription site.
- As the user selects to sign in, a request is sent to the `/login` endpoint of the site.
- After redirection, the user enters GitHub credentials to log in.

#### Gateway (OpenResty)

- Receives the log in request which is forwarded to the Autentication Service.
- Passes back redirections from the Authentication Service to the Web Browser.

#### Authentication Service

- Receives the log in request and redirects to external GitHub identity provider.
- After successful log in, redirection results in a request to the `/login/callback` endpoint with a temporary ticket
  received from the GitHub Identity Provided.
- Using the temporary ticket, obtains an access token from the GitHub Identity Provider.
- Creates session cookie and JWT.
- Stores the JWT in the Session DB.

#### Identity Provider (GitHub)

- Provides identifiers for users who wish to interact with the system.
- Verifies user credentials.

#### Session DB (Redis)

- Keeps track the user by storing the login session and associating login with the JWT.

## Access to Protected Resources

When a user is logged in, access to protected resources is done by passing the session cookie in requests. Before
giving access to the protected resource, the Gateway looks up the session in the Session DB to find its associated JWT
which is never exposed to the client.

The Gateway can then route the requests to the protected resources and pass the JWT as bearer token. The protected
resource validates the JWT to ensure that access is only granted to logged in users.
