# Proposal

## Why

No one can create an account: submitting the sign-up form raises `NoMethodError`, because `Users::RegistrationsController` calls `devise_parameter_sanitizer.for`, which Devise 4 removed. New customers can't buy anything, since checkout needs a signed-in user. The test baseline records this as its one pending example.

## What Changes

- Sign-up works again. A visitor gives a name, email, password and confirmation, and gets an account. They're signed in, land on the index page with an empty cart, and receive the welcome email.
- A sign-up with a taken email, a short password or a mismatched confirmation creates nothing and shows the form again with the reasons.
- Sign-up can never create an admin. Only name, email and password are accepted, so a `role` sent with the form is ignored. This matters now that the admin pages check the role.
- The custom `create` that bypassed Devise is replaced by Devise's own, plus a small hook for the cart and the welcome email.
- The unused `app/controllers/registrations_controller.rb` is removed. No route points at it.
- The pending sign-up example in `spec/requests/sessions_spec.rb` becomes real specs.

## Capabilities

### New Capabilities

- `customer-accounts`: how visitors become customers: signing up, what an account starts with, and what sign-up can't grant.

### Modified Capabilities

None.

## Impact

- Changed: `app/controllers/users/registrations_controller.rb`, `spec/requests/sessions_spec.rb`.
- New: `spec/requests/registrations_spec.rb`.
- Removed: `app/controllers/registrations_controller.rb`.
- Production: a deploy with the README's build steps. The welcome email goes out over the production SMTP settings, like order emails.
- Out of scope: account editing (`/users/edit`); the duplicate `UserMailer` in `app/controllers/user_mailer.rb`; the welcome email's wording.
