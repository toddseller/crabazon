# Design

## Context

See proposal.md, Why.

- **Already in place:**
  - the users table has `confirmation_token`, `confirmed_at` and `confirmation_sent_at`;
  - the Devise initializer sets `allow_unconfirmed_access_for = 2.days` and `reconfirmable = true`;
  - `User` doesn't include `:confirmable`, and there's no `unconfirmed_email` column.
- **Sign-up today:** `Users::RegistrationsController#create` calls Devise's `create`. On success it sets an empty cart and sends `UserMailer.welcome_email` with `deliver_now`.
- **Background sending:** reset-hardening already sends Devise's emails with `deliver_later`, and keeps their arguments out of the log.
- **Email design:**
  - `user_mailer/welcome_email.html.erb` and `order_email.html.erb` are each a full HTML document with the same shell: head styles, a logo header, a content block, and a footer with a small logo;
  - `UserMailer` also wraps them in `layouts/mailer.html.haml`, a two-line wrapper;
  - Devise's emails use no layout.

## Goals / Non-Goals

**Goals:** confirmation before the first sign-in; the same answer for a taken address; one shared email design for the account emails.

**Non-Goals:**
- email-change confirmation (`reconfirmable`);
- the account edit page;
- the order email's markup;
- plain-text parts for the account emails.

## Decisions

### Devise's `:confirmable`, with no grace period

- **The settings:** add `:confirmable` to `User`, and set `allow_unconfirmed_access_for = 0.days` and `reconfirmable = false`.
- **Why no grace period:** with the 2-day grace, a new sign-up is signed in at once, which a taken address can't copy.
- **Why no reconfirmable:** it needs an `unconfirmed_email` column, and it only covers email changes on the edit page, which is out of scope.

### A migration marks existing users confirmed

The migration runs `UPDATE users SET confirmed_at = created_at WHERE confirmed_at IS NULL`.
- **Why `created_at`:** it's a truthful "confirmed since". Without the update, every existing customer would be locked out.
- **Down step:** it does nothing. The column existed before, and rolling the code back drops `:confirmable`, so the values are harmless.

### `create` handles the taken address itself

`Users::RegistrationsController#create` is written out instead of calling `super`. Devise's `create` renders after its block runs, so the block can't swap in a redirect. The steps:
1. Build the user and save it.
2. If the save failed only because the email is taken, email the owner and redirect to the sent page, exactly as a new sign-up does. A confirmed owner gets `UserMailer.sign_up_attempt`. An owner who never confirmed gets the confirmation email again, since they can't sign in yet.
3. If it failed for other reasons as well, delete the `email: :taken` error and show the form with the rest. The form never shows a "taken" error.
4. On success, Devise has already queued the confirmation email (`deliver_later`, through `send_devise_notification`). Remove Devise's `signed_up_but_unconfirmed` notice, the way the reset flow removes its own, and redirect to the sent page.

**The sent page:**
- **Route:** `GET /users/sign_up/sent`, a `sent` action like the reset flow's, which reads the address from the flash. Its card says "We've sent an email to **x**. Open it to finish signing up", which is true in both cases.
- **Help text:** it suggests checking the spam folder, with a link to resend the confirmation.

**Timing:** both paths hash the password (Devise does that on assignment), run the uniqueness query, and queue one email. Only the new path inserts a row, which takes a few milliseconds.

**Alternative rejected:** checking `User.exists?` before Devise's `create`. That's a second query, and it would still need the error-stripping for the mixed case.

### After confirming

Devise's `confirmations#show` confirms the account and redirects to sign-in with "Your email address has been successfully confirmed." Devise no longer signs people in from the link, by design.
- **The cart:** `ApplicationController#cart` creates it at first sign-in, so the empty-cart line in `create` goes.
- **Resend page:** Devise's `confirmations#new` uses paranoid mode, like the reset form. It gets the shared card view.

### One email layout, cut from the welcome email

- **The layout:** `layouts/email.html.erb` is the welcome email's document with its content block replaced by `yield`:
  - head and styles;
  - logo header;
  - the content block's outer tables;
  - the footer, minus the unsubscribe line.

  `content_for(:title)` sets the `<title>`.
- **The button:** `shared/_email_button.html.erb` holds the orange button table, with a URL and a label.
- **Which mailers use it:**
  - Devise's mailer, via `config.to_prepare { Devise::Mailer.layout 'email' }` in `config/application.rb`;
  - `UserMailer#sign_up_attempt`, by passing the layout to its `mail` call.

  `UserMailer` keeps `layouts/mailer` for the order email, which stays as it is.
- **Each email's content:**
  - **confirmation:** the welcome heading and paragraphs, then a "Confirm your email" button;
  - **reset:** "Reset your password", one paragraph, a "Choose a new password" button, and the 6-hour and ignore-it lines;
  - **taken-address notice:** "Someone tried to sign up with your address", a "Sign in" button, and a reset link.

  Their subjects are "Welcome to Crabazon", "Reset your Crabazon password" and "Someone tried to sign up with your Crabazon address", set through the Devise locale and the mailer.
- **The welcome email** (method, views and request spec) is deleted.

### Specs create confirmed users

Each spec's `User.create!` gets `confirmed_at: Time.current`. That's 17 call sites in 8 files. Specs about confirmation itself create users without it.
- **Alternative rejected:** a global hook that confirms every user, which would hide the behavior under test.

## Risks / Trade-offs

- **[Users made by hand]** A user created with `rails runner` or `db/seeds.rb` after this change can't sign in until confirmed. → `db/seeds.rb` gets `confirmed_at`. The README has no instructions for creating users, so there's nothing to update there; anyone doing it by hand passes `confirmed_at: Time.current`.
- **[Mail failure means no sign-in]** If the mail server is down, a new customer can't finish signing up, where today they're signed in at once. → They can use the resend link once it's back. That's the cost of proving the address.
- **[Email clients]** The layout is the welcome email's existing markup, so it renders the way the welcome email already does.

## Migration Plan

1. Deploy with the README's steps. Its `db:migrate` step runs the confirmed-at migration. Nobody is signed out.
2. Owner checks:
   - still signed in;
   - sign up with a new address: the "Check your email" page appears, the confirmation email arrives in the new design, the link opens sign-in, and signing in works;
   - sign up again with the same address: the same page appears, and the notice email arrives;
   - a password reset email arrives in the new design.
3. Rollback: the README's steps, running `db:rollback` first. That rollback does nothing to the data, and the old code ignores `confirmed_at`.
