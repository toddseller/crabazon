# database-access Specification

## Purpose

How the app reaches its database: as a login limited to that one database, with its password kept out of the repository and out of `.env`.

## Requirements

### Requirement: A login limited to the app's database
The deployed app SHALL connect to its database as a login that is not a superuser and owns that database and every table and sequence in it, so migrations succeed and nothing else on the server is reachable with its password.

#### Scenario: The deployed app's login
- **WHEN** the deployed app runs `SELECT current_user`
- **THEN** it gets `crabazon_app`, which is not a superuser

#### Scenario: Every object owned
- **WHEN** the database's tables, sequences and the database itself are listed with their owners
- **THEN** every one is owned by `crabazon_app`

### Requirement: Database password from a file outside the repository
When `PGPASS_FILE` in `.env` names a password file on the host, the web container SHALL read the database password from that file, mounted read-only, so `DATABASE_URL` can omit the password. Without `PGPASS_FILE`, the password in `DATABASE_URL` SHALL work as before.

#### Scenario: Password from the file
- **WHEN** `PGPASS_FILE` names a password file holding a line for the database and `DATABASE_URL` has no password
- **THEN** the app connects and serves pages

#### Scenario: No password file
- **WHEN** `PGPASS_FILE` is unset and `DATABASE_URL` includes the password
- **THEN** the container starts with no file to mount and the app connects as before
