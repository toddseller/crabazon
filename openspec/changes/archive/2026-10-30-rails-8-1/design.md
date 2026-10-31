# Design

## Context

A trial run on October 30, in a worktree of `master`, set `gem 'rails', '~> 8.1.0'` and ran `bundle update rails --conservative` on `ruby:3.4.12` against `postgres:18`:

- **Gems:** Rails resolves to 8.1.4. Besides Rails' own gems, the lockfile adds `action_text-trix` and drops `benchmark`. Rack (2.2.9), `concurrent-ruby` (1.3.8), Devise (4.9.3), rspec-rails (6.1.2) and `sprockets-rails` (3.4.2) don't move.
- **Suite:** 34 examples, 0 failures, and `zeitwerk:check` passes.
- **Deprecations:**
  - "`config.active_support.to_time_preserves_timezone` is deprecated", from the line the 8.0 step added. Removing the line clears it.
  - Four "resource received a hash argument" warnings (`controller`, `only`, `path`, `path_names`) from `config/routes.rb:2`, `devise_for`. They come from Devise's own route code (`lib/devise/rails/routes.rb`), which calls `resource` with a hash. Devise 4.9.4 is the same.
- **Devise 5:** an unpinned `bundle update devise` resolves to Devise 5.0.4. That clears the route warnings, but fails one spec: "Sessions refuses a wrong password" no longer finds "Invalid Email or password." in the response.
- **Production mode,** with the `to_time` line removed:
  - the image builds and compiles assets;
  - the server boots as Rails 8.1.4;
  - `/`, sign-in, forgot-password, the stylesheet and the script return 200, and `/admin` redirects to sign-in.

## Goals / Non-Goals

**Goals:**
- Rails 8.1, with the shop behaving exactly as before, and sessions kept across the deploy and a rollback.

**Non-Goals:**
- Devise 5. It changes sign-in failure behavior, which deserves its own change and spec work.
- Rails 8.1 framework defaults.

## Decisions

1. **Pin `~> 8.1.4` and update conservatively,** as in the earlier steps.
2. **Delete the `to_time_preserves_timezone` line.** 8.1 always behaves the way it set, so deleting it changes nothing.
3. **Leave Devise's route warnings for the Devise 5 change.** They only matter for Rails 8.2, which isn't out. Silencing them on 4.9 would mean patching Devise.
4. **No `load_defaults`.** The production-mode check reuses cookies between an 8.0 and an 8.1 container in both directions.

## Risks / Trade-offs

- [Rails 8.1 changes something the specs don't cover] → The production-mode run checks pages, assets and admin sign-in. After deploy, the owner signs in, uses the cart, checks out and edits a product.
- [Sessions break across the deploy or a rollback] → Checked in both directions before deploy.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check:
   - the startup log shows Rails 8.1.4;
   - the pages return 200, and `/admin` redirects to sign-in;
   - the owner signs in, uses the cart, checks out (the email arrives), and edits a product.
4. Rollback: the README's rollback steps. No migrations, and cookies stay readable by 8.0.
