# Proposal

## Why

A customer who asks for a password reset in production gets "We're sorry, but something went wrong." The production log shows `ActionView::Template::Error (Missing host to link to!)` from the reset email's template. That email must contain a full link back to the shop, and production has never been told the shop's address. The welcome and order emails have no links, so they've always worked. As a result, no customer can recover an account.

The reset email would also come from Devise's placeholder sender, `please-change-me-at-config-initializers-devise@example.com`, which mail servers and spam filters are likely to reject.

## What Changes

- Production builds email links for `https://crabazon.us`, the shop's public address, served by its Cloudflare tunnel.
- Tests build email links for `www.example.com`, the host request specs already use, so the reset flow can be tested end to end.
- Devise's emails come from `Crabazon <crabazon@toddseller.com>`, the sender the welcome and order emails use.
- `app/controllers/users/passwords_controller.rb` is deleted. No route uses it, and its one override, redirecting to `signed_in_root_path` after a reset, is what Devise already does.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `customer-accounts`: adds password reset. A customer who asks for a reset gets an email with a working link, and can sign in with the new password.

## Impact

- Changed: `config/environments/production.rb`, `config/environments/test.rb`, `config/initializers/devise.rb`.
- New: `spec/requests/passwords_spec.rb`.
- Deleted: `app/controllers/users/passwords_controller.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations.
- Out of scope:
  - development's mail settings;
  - Devise's `devise_error_messages!` deprecation.
