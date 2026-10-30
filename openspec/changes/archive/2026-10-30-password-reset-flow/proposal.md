# Proposal

## Why

Password reset works up to the last step, then fails in three ways the owner hit in production on October 30:

- **Redirect loop.** After a new password is saved, the customer is signed in and redirected to the reset page they came from. That page is for signed-out visitors, so Devise redirects them back to it again, until the browser stops with "redirected you too many times". The password did change; the customer just never lands anywhere. The cause is `ApplicationController#after_sign_in_path_for`, which falls back to `request.referer`. Sign-in doesn't loop only because `Users::SessionsController` has its own version: admins go to `/admin`, customers to `/index`.
- **No cart, so the shop crashes.** Once out of the loop, the owner was signed in, but the home page returned 500 (`undefined method '[]' for nil` at `index/index.html.haml:20`) until they cleared their cookies. The product listings read `session[:cart][...]` for any signed-in user, and only sign-in and sign-up create that cart. A reset signs the customer in without one. A "Remember Me" sign-in on a later visit, with a fresh session, very likely does the same.
- **Unstyled pages.** The forgot-password and change-password pages are Devise's generated markup: no logo, no card, plain browser inputs and buttons. Sign-in and sign-up sit in a styled card.

## What Changes

- One `after_sign_in_path_for`, in `ApplicationController`: admins go to `/admin`, everyone else to `/index`. It replaces the referer-based version, and `Users::SessionsController`'s copy is deleted. After a reset, and whenever a signed-in user opens a signed-out page (sign-in, sign-up, forgot or change password), they land where sign-in sends them.
- Every request from a signed-in user without a cart gets an empty one, in `ApplicationController#cart`, which already runs before every action and reads the cart. Sign-in and sign-up still empty it, as today.
- One card partial, `devise/shared/_card.html.erb`, holding the frame sign-in and sign-up already share: logo, title, the page's form, and the Devise links. Sign-in, sign-up, forgot-password and change-password all render inside it, and the two password forms use the same field and button classes as sign-in.
- The unused `devise/sessions/new.html.haml` is deleted. The sign-in page renders the `.erb` version.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `customer-accounts`: password reset ends with the customer signed in on the index page, with an empty cart.

## Impact

- Changed:
  - `app/controllers/application_controller.rb`, `app/controllers/users/sessions_controller.rb`;
  - `app/views/devise/sessions/new.html.erb`, `app/views/devise/registrations/new.html.erb`;
  - `app/views/devise/passwords/new.html.erb`, `app/views/devise/passwords/edit.html.erb`;
  - `spec/requests/passwords_spec.rb`.
- New: `app/views/devise/shared/_card.html.erb`.
- Deleted: `app/views/devise/sessions/new.html.haml`.
- Production: one image rebuild and restart, with the README's rollback. No migrations.
- Behavior note: a signed-in user who opens sign-up or forgot-password from a product page lands on `/index` instead of back on that product.
- Out of scope:
  - Devise's `devise_error_messages!` deprecation (the password forms keep the helper they use today);
  - the hardcoded, fingerprinted logo path that many views share;
  - the account edit, confirmation and unlock pages (no links reach them).
