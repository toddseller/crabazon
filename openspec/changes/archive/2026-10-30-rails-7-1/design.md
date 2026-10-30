# Design

## Context

A trial run on October 30, in a worktree of `master`, set `gem 'rails', '~> 7.1.6'` and ran `bundle update rails --conservative` on `ruby:3.4.12` against `postgres:18`:

- **Gems:**
  - Rails resolves to 7.1.6, and Rack stays at 2.2.9;
  - new or newer dependencies: `cgi`, `connection_pool`, `erb`, `io-console`, `irb`, `loofah`, `pp`, `prettyprint`, `prism`, `rack-session`, `rackup`, `rails-html-sanitizer`, `rbs`, `rdoc`, `reline`, `tsort` and `webrick`;
  - `concurrent-ruby` (1.2.3) and Devise (4.9.3) don't move.
- **Boot:** every spec errored at boot with `ArgumentError: The legacy_connection_handling setter was deprecated in 7.0 and removed in 7.1`.
- **After removing that line** and setting `cache_format_version = 7.1`:
  - the suite gives 33 examples, 0 failures, and `zeitwerk:check` passes;
  - two deprecations remain: Devise's `devise_error_messages!`, and `Rails.application.secrets`.
- **Where the `secrets` warning comes from:** Devise's `SecretKeyFinder`. It checks `Rails.application.secrets` while looking for a key, even though `config/secrets.yml` is gone. Devise 4.9.4 does the same. Rails 7.2 removes `secrets`, and the finder then skips that step.
- **Devise updates:** an unpinned `bundle update devise` resolves to Devise 5.0.4, which fails 4 specs.
- **Production mode:**
  - the image builds and compiles assets;
  - the server boots as Rails 7.1.6;
  - `/`, sign-in, forgot-password and the stylesheet return 200, and `/admin` redirects to sign-in.
- **Caching:** nothing in `app/` uses `Rails.cache`, and production sets no cache store.
- **Devise views:**
  - six templates call `devise_error_messages!`: passwords new and edit, registrations new and edit, confirmations new, and unlocks new;
  - the user model enables neither `:confirmable` nor `:lockable`, so no route reaches the last two;
  - in Devise 4.9 the helper only renders `devise/shared/error_messages`, so swapping in that partial gives the same HTML.

## Goals / Non-Goals

**Goals:**
- Rails 7.1, with the shop behaving exactly as before, and sessions kept across the deploy and a rollback.
- Nothing left that Rails 7.2 removes, apart from Devise's own `secrets` check, which goes away by itself on 7.2.

**Non-Goals:**
- Rails 7.1 framework defaults.
- Devise 5.

## Decisions

1. **Pin `~> 7.1.6` and update conservatively,** as in the 7.0 step.
2. **Set `cache_format_version = 7.1` in `config/application.rb`** instead of the removed line. That's the value `load_defaults 7.1` would set. With no `Rails.cache` use, there are no stored entries for a rollback to misread.
3. **Leave Devise's `secrets` warning.** Silencing it means setting `config.secret_key` in the Devise initializer, which only the previous change removed. Rails 7.2 ends the warning without any code.
4. **Replace the helper with the partial,** and delete the two templates for modules the app doesn't use rather than edit them. A new spec assertion pins the error output on the forgot-password form, which no spec covered: an unknown email shows "Email not found". Sign-up's error assertions cover the other form.
5. **No `load_defaults`.** Rails 7.1's defaults change the cookie serializer and key derivation, which would sign everyone out and break a rollback. The production-mode check reuses cookies between a 7.0 and a 7.1 container to prove both directions.

## Risks / Trade-offs

- [Rails 7.1 changes something the specs don't cover] → The production-mode run checks pages, assets, admin sign-in and the reset flow's pages. After deploy, the owner signs in, uses the cart, checks out and edits a product.
- [Sessions break across the deploy or a rollback] → Checked before deploy in both directions with the same `SECRET_KEY_BASE`.
- [Rails 7.1 is itself out of support] → It's a stepping stone. Rails 7.2 follows next.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check:
   - the startup log shows Rails 7.1.6;
   - the pages and assets return 200, and `/admin` redirects to sign-in;
   - the owner signs in, uses the cart, checks out (the email arrives), and edits a product.
4. Rollback: the README's rollback steps. No migrations ran, and cookies stay readable by 7.0.
