# Design

## Context

A throwaway run on October 30 in a copy of the repo set `gem 'rails', '~> 7.0.8'` and ran `bundle update rails --conservative` on `ruby:3.4.12` against `postgres:18`:

- **Gems:** Rails resolves to 7.0.10. `concurrent-ruby` (1.2.3), Devise (4.9.3), rspec-rails (6.1.2) and sprockets-rails (3.4.2) don't move.
- **Autoloading:** `bin/rails zeitwerk:check` passes.
- **Suite:** 31 examples, 0 failures.
- **Deprecations:** legacy connection handling, `Time#to_s(:long)` in `orders/index.html.haml`, and Devise's `devise_error_messages!`. Setting `legacy_connection_handling = false` and using `to_fs(:long)` cleared the first two, with the suite still green.
- **Production mode:**
  - `assets:precompile` compiles the stylesheet and script;
  - the server boots as Rails 7.0.10;
  - `/`, a product page and the sign-up form return 200, and `/admin` redirects to sign-in;
  - the assets return 200;
  - a real admin sign-in reaches `/admin`.
- **Mailer:** under Zeitwerk, `UserMailer` is loaded from `app/controllers/user_mailer.rb` (sender `crabazon@toddseller.com`). Production on 6.1 loads the same file today, which I confirmed on the app host with `rails runner`. `app/mailers/user_mailer.rb` is identical apart from the sender (`admin@crabazon.us`), and nothing loads it.
- **Session cookies:** `config/initializers/cookies_serializer.rb` sets `:json`. No `config.load_defaults` line exists.

## Goals / Non-Goals

**Goals:**
- Rails 7.0 with the shop behaving exactly as before: same pages, same emails and sender, sessions and carts kept across the deploy.
- Leave nothing that Rails 7.1 removes.

**Non-Goals:**
- Turning on Rails 7.0's new framework defaults. That's a separate, deliberate step, because some of them change cookies and security headers.
- Gem updates beyond what Rails 7.0 requires.

## Decisions

1. **Pin `~> 7.0.10` and update conservatively** (`bundle update rails --conservative`), so only Rails and its new or tightened dependencies move. Alternative: a full `bundle update`, which would pull `concurrent-ruby` 1.3.5 and break boot.

2. **Keep the sender production uses today.**
   - `git mv app/controllers/user_mailer.rb app/mailers/user_mailer.rb`, which replaces the unused copy, so the mailer lives where Rails expects it and only one definition exists.
   - The `from` assertions go in first, against 6.1, to record today's sender, and they must stay green through the upgrade.
   - Alternative: keep the `app/mailers` copy. That silently changes the sender to `admin@crabazon.us`, which the owner hasn't asked for.

3. **No `load_defaults`.** Rails 7.0's defaults include a SHA256 key generator for signed and encrypted cookies. Turning that on would invalidate every session, logging customers out and emptying carts, and a rollback to 6.1 couldn't read the new cookies. Without `load_defaults`, cookie signing stays as it is. The production-mode check signs in on the 6.1 image and reuses that cookie on the 7.0 image to prove it.

4. **Fix the two deprecations Rails 7.1 removes,** with one config line and one view change, so the next step starts clean.

## Risks / Trade-offs

- [Rails 7.0 changes something the specs don't cover] → The production-mode run checks pages, assets and admin sign-in. After deploy, the owner signs in, uses the cart, checks out (which sends a real order email) and edits a product.
- [Sessions break across the deploy] → Checked before deploy by moving a signed-in cookie from a 6.1 container to a 7.0 container with the same `SECRET_KEY_BASE`.
- [Rails 7.0 is itself past end of life] → It's a stepping stone. Rails 7.1 follows next.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check:
   - the startup log shows Rails 7.0.10;
   - the pages and assets return 200, and `/admin` redirects to sign-in;
   - the owner signs in, uses the cart, checks out (and the email arrives from `crabazon@toddseller.com`), and edits a product.
4. Rollback: the README's rollback steps. No migrations ran, and the cookies stay readable by 6.1.
