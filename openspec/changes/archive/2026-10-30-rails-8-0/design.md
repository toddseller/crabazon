# Design

## Context

A trial run on October 30, in a worktree of `master`, set `gem 'rails', '~> 8.0.0'` and ran `bundle update rails --conservative` on `ruby:3.4.12` against `postgres:18`:

- **Gems:** Rails resolves to 8.0.5.1. Besides Rails' own gems, the lockfile adds `uri` and drops `cgi`. These don't move:
  - Rack (2.2.9), `concurrent-ruby` (1.3.8) and Devise (4.9.3);
  - rspec-rails (6.1.2) and `database_cleaner-active_record`;
  - the asset gems: `sprockets` 4.2.1, `sprockets-rails` 3.4.2, `sass-rails` 6.0.0 and `uglifier`.
- **Suite:** 34 examples, 0 failures, and `zeitwerk:check` passes.
- **Deprecation:** one is new: "`to_time` will always preserve the receiver timezone rather than system local time in Rails 8.1", raised at boot.
- **`to_time` and time zones:** nothing in `app/`, `lib/` or `config/` calls `to_time` or sets a time zone. The production container runs in UTC, so "system local time" and UTC are the same there.
- **Production mode:**
  - the image builds and compiles assets;
  - the server boots as Rails 8.0.5.1;
  - `/`, sign-in, forgot-password, the stylesheet and the script return 200, and `/admin` redirects to sign-in.

## Goals / Non-Goals

**Goals:**
- Rails 8.0, with the shop behaving exactly as before, and sessions kept across the deploy and a rollback.
- No deprecation warnings left for 8.1.

**Non-Goals:**
- Rails 8.0 framework defaults, or adopting the new default stack.

## Decisions

1. **Pin `~> 8.0.5` and update conservatively,** as in the earlier steps.
2. **Set `to_time_preserves_timezone = :zone` in `config/application.rb`,** next to the cache format setting. It's 8.1's only behavior, so setting it now leaves nothing to change later. With no `to_time` calls and a UTC server, it changes nothing today.
3. **No `load_defaults`.** The production-mode check reuses cookies between a 7.2 and an 8.0 container in both directions.

## Risks / Trade-offs

- [Rails 8.0 changes something the specs don't cover] → The production-mode run checks pages, assets and admin sign-in. After deploy, the owner signs in, uses the cart, checks out and edits a product.
- [Sessions break across the deploy or a rollback] → Checked in both directions before deploy.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check:
   - the startup log shows Rails 8.0.5.1;
   - the pages return 200, and `/admin` redirects to sign-in;
   - the owner signs in, uses the cart, checks out (the email arrives), and edits a product.
4. Rollback: the README's rollback steps. No migrations, and cookies stay readable by 7.2.
