# Design

## Context

- **Production key:** on October 30 the live `SECRET_KEY_BASE` in the app host's `.env` was rotated to a new random value, because it equaled the production value committed in `config/secrets.yml`. Rails 7.0 reads `ENV["SECRET_KEY_BASE"]` before `secrets.yml`, and production now confirms Rails uses the environment value.
- **Development and test:** in those environments, Rails 7.0 uses `secrets.secret_key_base` when set, and otherwise generates and stores one in `tmp/development_secret.txt`. `/tmp` is in `.gitignore` and `tmp/` in `.dockerignore`.
- **Image build:** the Dockerfile runs `assets:precompile` without `RAILS_ENV`, so in development, where a missing key is generated instead of raising.
- **Devise:** `config.secret_key` is a literal. With it removed, Devise 4.9's `SecretKeyFinder` tries credentials (none exist), then secrets, then `config.secret_key_base`, then `Rails.application.secret_key_base`. Without `secrets.yml`, that resolves to the app's key: the environment value in production. The app uses `:recoverable`, so Devise's key digests password-reset tokens; the app doesn't use confirmable or lockable.

## Goals / Non-Goals

**Goals:**
- No signing key in the repo; production's only key comes from the environment.
- No change for signed-in shoppers.

**Non-Goals:**
- Rewriting git history. The old values are public already and are unused after this change.
- Moving to Rails encrypted credentials. The environment variable already works, and Rails 7.1 and later keep reading it.

## Decisions

1. **Delete the file rather than switch production to `<%= ENV["SECRET_KEY_BASE"] %>`.** The environment already wins over the file, and Rails 7.2 drops `secrets.yml`. Deleting is less code and matches where Rails is going.
2. **Remove Devise's literal rather than set it from the environment.** Devise falls back to the app's key by default, so one secret covers both. A separate Devise key would be a second secret to manage for no gain.
3. **Test-first on Devise's key.** `expect(Devise.secret_key).to eq(Rails.application.secret_key_base)` fails today because of the literal, and passes once it's gone. The production check below proves the file deletion: production refuses to boot without `SECRET_KEY_BASE`, so no committed fallback remains.

## Risks / Trade-offs

- [Password-reset links sent before the deploy stop working] → Accepted. Customers can request a new link, and this shop sends few of them.
- [Production starts without `SECRET_KEY_BASE` set] → It now refuses to boot instead of quietly using a public key. That's the intended behavior. The host's `.env` sets it, and the production-mode check confirms both cases.
- [Sessions lost] → The Rails key doesn't change, so cookies stay valid. Checked by signing in on an image built from `origin/master` and reusing that cookie on the new image with the same `SECRET_KEY_BASE`.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check:
   - the startup log shows Rails 7.0.10;
   - `/` and a product page return 200, and `/admin` redirects to sign-in;
   - the owner stays signed in across the deploy, and a password-reset email's link works.
4. Rollback: the README's rollback steps. No migrations, and the rolled-back image also prefers the environment key.
