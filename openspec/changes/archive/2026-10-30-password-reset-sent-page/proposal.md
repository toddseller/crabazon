# Proposal

## Why

The owner tested the reset in production on October 30 and found two rough edges on the forgot-password page:

- **The button turns blue.** Rails disables a submit button while its form is sending (`data-disable-with`). Bootstrap 3 paints a disabled `btn-primary` blue (`#337ab7`), and the shop overrides only the hover, active and focus colors, not the disabled ones. Log In has the same behavior, but signing in returns at once. Sending the reset email waits on the mail server, so the blue stays long enough to see.
- **It looks like nothing happened.** After the email is sent, Devise redirects to the sign-in page with a small notice at the top. To the customer, it looks like being sent back to log in.

## What Changes

- After a reset email is sent, the customer lands on a new page, in the same card as the other account pages, titled "Check your email". It says a reset link was sent to the address they entered, that the link works for 6 hours, and to check spam. It has a link back to sign-in. Devise's notice at the top no longer shows, because the page says it.
- Disabled primary buttons keep the shop's orange. Bootstrap's own disabled look still fades them, so a button that is working looks busy rather than changing color.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `customer-accounts`: asking for a reset ends on a page that names the address the email went to. The requirement is split in two, one for the email and confirmation and one for signing in after the reset, because together they ran past OpenSpec's strict length limit.

## Impact

- New:
  - `app/controllers/users/passwords_controller.rb`;
  - `app/views/devise/passwords/sent.html.erb`;
  - a `GET /users/password/sent` route.
- Changed:
  - `config/routes.rb` (Devise uses the new passwords controller);
  - `app/assets/stylesheets/styles/products_controller.scss`;
  - `spec/requests/passwords_spec.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations.
- Out of scope:
  - asking for a reset with an unknown email, which still shows "Email not found" on the form;
  - the other account forms, which only get the button color.
