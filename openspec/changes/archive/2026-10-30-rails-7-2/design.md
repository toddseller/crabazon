# Design

## Context

A trial run on October 30, in a worktree of `master`, set `gem 'rails', '~> 7.2.0'` and ran `bundle update rails --conservative` on `ruby:3.4.12` against `postgres:18`:

- **Gems:** Rails resolves to 7.2.3.2. Besides Rails' own gems, `concurrent-ruby` moves from 1.2.3 to 1.3.8 and `useragent` is added. Rack (2.2.9), Devise (4.9.3) and rspec-rails (6.1.2) don't move.
- **Suite:** it stopped at `DatabaseCleaner.clean_with(:truncation)` with `undefined method 'schema_migration'` from `database_cleaner-active_record` 2.1.0. After `bundle update database_cleaner-active_record --conservative` (to 2.2.2):
  - 34 examples, 0 failures, and `zeitwerk:check` passes;
  - no deprecation warnings at all; Devise's `secrets` check ended with 7.2.
- **`show_exceptions`:**
  - in 7.1, `ActionDispatch::ExceptionWrapper#show?` still mapped `true` and `false` with a deprecation;
  - in 7.2 it handles only `:none` and `:rescuable`, and everything else, `false` included, means "show";
  - `config/environments/test.rb` sets `false`, under a comment saying exceptions should raise.
- **Better Errors** (found while applying): `better_errors` sits in the `:development, :test` group. Its Railtie inserts its middleware whenever the app isn't in production and `consider_all_requests_local` is true, and `test.rb` sets that. With a `raise` in the index view, the storefront spec got a 500 page under both `false` and `:none`. Specs have never seen real exceptions.
- **Production mode:**
  - the image builds and compiles assets;
  - the server boots as Rails 7.2.3.2;
  - `/`, sign-in, forgot-password and the stylesheet return 200, and `/admin` redirects to sign-in.

## Goals / Non-Goals

**Goals:**
- Rails 7.2, with the shop behaving exactly as before, and sessions kept across the deploy and a rollback.
- Specs see real exceptions, not error pages.

**Non-Goals:**
- Rails 7.2 framework defaults.
- Updating gems beyond what 7.2 needs.

## Decisions

1. **Pin `~> 7.2.3` and update conservatively,** as in the earlier steps. Let `concurrent-ruby` move: Rails 7.2 requires 1.3.1 or later, and the 1.3.5 break hit only Rails 7.0 and earlier.
2. **Update only `database_cleaner-active_record`,** conservatively. Replacing DatabaseCleaner with Rails' transactional fixtures would also work, but it changes how every spec isolates data. That's a separate decision, not part of an upgrade.
3. **Set `show_exceptions = :none` before the upgrade.** 7.1 already accepts `:none`, so the suite proves the change on its own.
4. **Move `better_errors` and `binding_of_caller` to a `:development` group.** `binding_of_caller` only exists to serve Better Errors. With both changes, a deliberately broken view makes the spec fail with the real exception.
   - Alternative: turn Better Errors off in `test.rb`. That's more config for a gem the tests never use.
5. **No `load_defaults`.** The production-mode check reuses cookies between a 7.1 and a 7.2 container in both directions.

## Risks / Trade-offs

- [`concurrent-ruby` 1.3.8 behaves differently at runtime] → The suite and the production-mode run exercise boot, requests and mail. After deploy, the owner runs the usual checks.
- [Sessions break across the deploy or a rollback] → Checked in both directions before deploy.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check:
   - the startup log shows Rails 7.2.3.2;
   - the pages return 200, and `/admin` redirects to sign-in;
   - the owner signs in, uses the cart, checks out (the email arrives), and edits a product.
4. Rollback: the README's rollback steps. No migrations, and cookies stay readable by 7.1.
