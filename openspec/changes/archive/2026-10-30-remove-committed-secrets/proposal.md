# Proposal

## Why

The repo is public, and it commits two signing keys:
- `config/secrets.yml` has `secret_key_base` values for development, test and production. Until the rotation on October 30, the production value was the live key.
- `config/initializers/devise.rb` sets a literal `config.secret_key`, which Devise uses to digest password-reset tokens.

Production now reads a new, private `SECRET_KEY_BASE` from the app host's `.env`. Both committed values still sit in the code, ready to be used again by mistake. Rails 7.1 also deprecates `secrets.yml`, and Rails 7.2 removes it, so the file has to go before the upgrade anyway.

## What Changes

- Delete `config/secrets.yml`. Production already takes `SECRET_KEY_BASE` from the environment, which wins over the file. Development and test fall back to the key Rails generates in `tmp/development_secret.txt`, which git and Docker ignore.
- Remove the literal `config.secret_key` from `config/initializers/devise.rb`. Devise then uses the app's `secret_key_base`, which in production is the private key from the environment.
- A spec pins that Devise's key is the app's `secret_key_base`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. Shoppers see no change, so the change carries no spec deltas.

## Impact

- Deleted: `config/secrets.yml`.
- Changed: `config/initializers/devise.rb`.
- New: `spec/initializers/devise_spec.rb`.
- Production: one image rebuild and restart, with the README's rollback. Sessions and carts survive, because the Rails key doesn't change. Password-reset links emailed before the deploy stop working, because Devise's key changes; customers can request a new one.
- Out of scope:
  - purging the old values from git history (they're public already, and both are now unused);
  - the Rails 7.1 step, which follows.
