# Design

## Context

- **Production failure:** on October 30, a reset request in production saved a reset token, rendered `devise/mailer/reset_password_instructions.html.erb`, and failed at `edit_password_url(...)` with "Missing host to link to!". `git log` shows `config/environments/production.rb` never set `action_mailer.default_url_options`, so the failure predates the Rails and secrets changes.
- **Public address:** the app host's `crabazon-tunnel` (Cloudflare) serves the shop as `crabazon.us`. `https://crabazon.us/` returns 200, and `http://` redirects to it.
- **Sender:** `UserMailer` sends from `Crabazon <crabazon@toddseller.com>` through the production SMTP settings. Devise's `config.mailer_sender` is still the generated placeholder.
- **Routes:** `devise_for :users` overrides only the sessions and registrations controllers, so Devise's own passwords controller handles resets. With Devise's default `sign_in_after_reset_password`, a successful reset signs the customer in.
- **Tests:** the test environment sets no URL host either, so a reset request spec fails today with the same error production shows.

## Goals / Non-Goals

**Goals:**
- A customer can reset a forgotten password in production, end to end.

**Non-Goals:**
- Other Devise emails. Confirmable and lockable aren't enabled, so only the reset email has links.
- Development's mail setup.

## Decisions

1. **Commit `host: 'crabazon.us', protocol: 'https'` in `production.rb`** rather than reading it from `.env`. It's the shop's public address, and one line beats a variable that every deploy must set. Alternative: an environment variable. It would only pay off with more than one production address.
2. **Set `host: 'www.example.com'` in `test.rb`.** That's the host request specs already use, so the spec can follow the emailed link like a customer. The production value is checked in the production-mode run instead.
3. **Set Devise's `mailer_sender` to `UserMailer`'s sender,** so all the shop's mail comes from one address that its SMTP account sends as.

## Risks / Trade-offs

- [The SMTP provider rejects the reset email] → It sends from the same address and account as the welcome email, which arrives today. The owner tests a real reset after deploy.
- [The domain changes] → A one-line config change.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check:
   - the startup log shows Rails 7.0.10;
   - the owner requests a reset, the email arrives from `crabazon@toddseller.com`, its link opens `https://crabazon.us/users/password/edit?...`, and the new password signs in.
4. Rollback: the README's rollback steps. No migrations.
