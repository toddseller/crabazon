# Proposal

## Why

Devise 4.9's `devise_for` passes route options to Rails as a hash. Rails 8.1 deprecates that and removes it in 8.2, so on 8.2 the shop's sign-in routes would break. Those four warnings are the last deprecations in the suite. Devise 5 calls Rails with keywords instead.

## What Changes

- **Devise 4.9.3 to 5.0.4,** with `bundle update devise --conservative`. Only Devise changes in the lockfile.
- **The wrong-password message changes case:** "Invalid Email or password." becomes "Invalid email or password.". Devise 5 lowercases the field name in the middle of the sentence. The sessions spec matches the new wording.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. No spec requirement names the message text.

## Impact

- Changed: `Gemfile.lock`, `spec/requests/sessions_spec.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations. Sessions should carry over, which the production-mode check confirms.
- Out of scope: Devise 5's optional new settings and initializer changes.
