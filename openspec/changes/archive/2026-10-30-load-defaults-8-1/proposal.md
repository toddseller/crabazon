# Proposal

## Why

The app has never called `config.load_defaults`, so it still runs on the framework defaults Rails had before 5.0. The upgrade steps deliberately left them off. Turning them on now brings:

- **CSRF protection.** It's off in production today: `protect_from_forgery` is commented out in `ApplicationController`, and nothing else enables it. Any other site could make a signed-in visitor's browser change their cart, check out, or, for an admin, edit products.
- **Required `belongs_to`,** newer cookie encryption (AES-GCM with SHA256-derived keys), and the many smaller defaults from Rails 5.0 through 8.1.

## What Changes

- **`config.load_defaults 8.1`** replaces the single `cache_format_version = 7.1` line, which `load_defaults` already sets. The `cookies_serializer.rb` initializer is deleted, because `load_defaults` sets the same `:json` value.
- **Two dead associations are deleted.** `Product belongs_to :user` points at a `user_id` column the `products` table doesn't have, and `User has_many :products, through: :orders_products` goes through an association that doesn't exist. With `belongs_to` now required, the first one would refuse every product.
- **The checkout form carries a CSRF token.** It's a raw `%form` whose button posts through JavaScript, which jquery_ujs already gives the token. Pressing Enter in a quantity box submits the form natively, though, and without a token that's now refused.
- **Session cookies move to Rails 8.1's format,** as the owner chose on October 30. Everyone is signed out once on deploy, and carts are emptied. A rollback signs everyone out again. Password-reset links emailed before the deploy stop working, because the key derivation changes.

## Capabilities

### New Capabilities

- `request-protection`: requests that change something need a valid CSRF token.

### Modified Capabilities

None.

## Impact

- Changed:
  - `config/application.rb`;
  - `app/models/product.rb`, `app/models/user.rb`;
  - `app/views/orders/new.html.haml`.
- Deleted: `config/initializers/cookies_serializer.rb`.
- New: `spec/requests/forgery_protection_spec.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations. Every customer, the owner included, signs in again after the deploy.
- Out of scope:
  - account enumeration and rate-limiting the reset form;
  - Rack 3.
