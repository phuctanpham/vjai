# TASK-002: Securing PowerSync

> **Owner:** Engineering Manager  
> **Status:** Draft · implementation blocked by [BE-001](../backend/BE-001-platform-decision.md)  
> **Source:** Flow Spec T4 · [CHG-011 PowerSync security baseline](../../changes/CHG-011-power-sync-security-baseline.md)

## Analysis

This note is a deployment reference for the future P3/P4 platform, not an
implementation task. The current repository has no production authentication
service, PowerSync service, Nginx deployment or generated Android project.
The existing Flutter app already uses the approved `flutter_secure_storage`
abstraction for install identity and the SQLCipher key; no new dependency or
token path should be added from this note alone.

The techniques below are retained as requirements to adapt when the platform
is approved:

1. **JWT:** use RSA signing on the auth service and JWKS verification on
   PowerSync. Pin the accepted algorithm and `kid`; keep private keys only in
   the auth service's secret manager and define overlap/rollback for rotation.
2. **Authorization:** derive the owner from the verified JWT `sub` for every
   stream and write. Validate `user_id`, collection, operation and fields on
   the backend; do not trust client payload ownership.
3. **Transport and proxy:** require TLS and disable cleartext. Hide proxy
   version details and restrict `/probes/` to the monitoring network. Probes
   must not return tokens, configuration or data.
4. **Flutter connector:** obtain short-lived access tokens through the auth
   boundary and use `SecureStore` for refresh credentials. Never use ordinary
   preferences, hard-code endpoints or log credentials.
5. **Pinning:** treat SPKI pinning as optional until backup pins,
   certificate/proxy rotation, emergency recovery and all supported platforms
   are tested. Do not commit an example pin as production configuration.

## Operational examples (placeholders only)

The following commands illustrate the intended controls. They must be run only
in the deployment environment, with secrets supplied by its secret manager:

```bash
# Generate and publish a key through the auth-service key-management process.
openssl genpkey -algorithm RSA -out rsa_private.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in rsa_private.pem -out rsa_public.pem

# Validate proxy configuration before reload.
docker exec nginx-proxy nginx -t
docker exec nginx-proxy nginx -s reload
```

The JWKS values, sync endpoint, private key, client pin and network ranges are
environment-specific configuration. They must not be copied into Dart,
`service.yaml` committed to this repository, tests or documentation as live
values.

## Acceptance criteria for future implementation

- [ ] BE-001 approves the backend, auth and wire contracts.
- [ ] JWKS algorithm/key-ID allow-list and rotation/rollback are tested.
- [ ] Stream and write authorization tests prove owner isolation.
- [ ] TLS, probe restriction and secret-management checks run in deployment CI.
- [ ] Any certificate pin has backup pins and a tested recovery path.
- [ ] Flutter connector tests prove secure token access, retry behaviour and no
      token logging.

## Anti-scope

No PowerSync service, JWT issuer, Nginx configuration, certificate pin,
production endpoint, secret or new dependency is implemented under this task.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-011](../../changes/CHG-011-power-sync-security-baseline.md) | Reframed the note as a deferred security baseline and removed live-looking client configuration. |
