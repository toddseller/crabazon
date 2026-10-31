# Proposal

## Why

The password reset form tells anyone whether an email address has an account:
- **The message:** an unknown address gets "Email not found", and a known one goes to "Check your email". Anyone can test a list of addresses against the shop.
- **The timing:** the reset email is sent over SMTP before the page answers, so a known address also takes visibly longer.
- **No limit:** nothing stops someone from asking for reset emails to the same customer over and over, filling their inbox from the shop's address.

## What Changes

- **Same answer for every address.** Asking for a reset with any address leads to the same "Check your email" page. Its wording no longer claims an email was sent, because the page can't say whether the address has an account. Only real accounts get an email, as now.
- **Same timing.** Reset emails are sent in the background after the page answers, so a known address no longer takes longer.
- **A limit per address.** After 5 requests for the same address within an hour, more requests for it are turned away with a message to try again later. The limit counts any address, known or not, so it reveals nothing.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `customer-accounts`: the reset request answers the same way for any address, and requests per address are limited.

## Impact

- Changed:
  - `config/initializers/devise.rb`;
  - `app/models/user.rb`;
  - `app/controllers/users/passwords_controller.rb`;
  - `app/views/devise/passwords/sent.html.erb`;
  - `spec/requests/passwords_spec.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations, and nobody is signed out.
- Out of scope:
  - **Sign-up:** it still says "Email has already been taken", which reveals the same thing. Closing that needs emailed sign-up confirmation, which is a bigger change.
  - **Sign-in:** it already says "Invalid email or password." for both a wrong address and a wrong password.
  - **A limit per visitor IP:** with only real accounts getting emails, and each address limited, a per-IP limit adds little. It would also depend on which client address the Cloudflare tunnel passes through, which wasn't checked.
