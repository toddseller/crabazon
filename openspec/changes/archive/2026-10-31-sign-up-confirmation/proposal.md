# Proposal

## Why

Sign-up tells anyone whether an address has an account: "Email has already been taken". The reset form no longer gives this away, so sign-up is the last place that does.

To hide it, a taken address has to get exactly the same answer as a new one. Today a new sign-up is signed in at once and lands on the shop, which a taken address can't copy. So new accounts must first confirm their address by email, which also proves the address belongs to them.

The shop's emails also look inconsistent. The welcome and order emails share a designed layout, with the logo, a heading, text and an orange button. Devise's password reset email is three lines of plain HTML.

## What Changes

- **New accounts confirm their address before they can sign in.**
  - Sign-up leads to a "Check your email" page that names the address.
  - The confirmation link confirms the account and opens the sign-in page with a message.
  - Signing in before confirming is refused, with a link to send the confirmation again.
- **A taken address looks like a new sign-up.** It gets the same "Check your email" page. The address's owner gets a notice instead: someone tried to sign up with it, and if it was them, they can sign in or reset their password. A taken address combined with another mistake, such as a mismatched password, shows only the other mistake.
- **One email instead of two:** the confirmation email takes over the welcome email's heading and text, with a "Confirm your email" button. The separate welcome email goes away.
- **Every account email shares the welcome email's design.** Its frame becomes a shared layout used by the confirmation email, the new notice and the password reset email. The footer's "click here to unsubscribe" line goes, since its link went to `example.com`.
- **Existing accounts are marked confirmed** by the migration, so nobody already signed up notices a change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `customer-accounts`:
  - sign-up confirms the address before the first sign-in;
  - a taken address gets the same answer as a new one, and its owner gets a notice;
  - the account emails share the shop's design.

## Impact

- **Code:**
  - `app/models/user.rb`, adding `:confirmable`;
  - `config/initializers/devise.rb`, `config/application.rb` and `config/routes.rb`;
  - `app/controllers/users/registrations_controller.rb`;
  - `app/mailers/user_mailer.rb`.
- **Views:**
  - a new email layout and button partial;
  - the Devise confirmation and reset emails, the new notice email, and the deleted welcome email;
  - a new "Check your email" page for sign-up, and a styled resend-confirmation page.
- **Database:** a migration that marks existing users confirmed. `db/schema.rb` changes. The confirmation columns already exist.
- **Specs:** the specs that create users now create confirmed ones, plus new specs for the flow.
- **Production:** one image rebuild, restart and `db:migrate`, with the README's rollback. Nobody is signed out.
- **Out of scope:**
  - the account edit page, where changing your email to a taken one still says "Email has already been taken" (it needs an account to reach);
  - restyling the order email, which already uses the design.
