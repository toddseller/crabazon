# Proposal

## Why

The Ruby 2.6 to 4.0 and Rails 6.1 to 8.1 upgrade needs a test suite that says what each step broke, and crabazon has none that works: of 20 examples, 15 fail because they were written for Rails 4 and a column that no longer exists, 1 is a pending placeholder, and nothing runs them. A trial run showed the suite can run on today's stack in Docker against PostgreSQL 18, so the safety net can be built before any version changes.

## What Changes

- Request specs that pin down how the shop works today: browsing, the cart, sign-in, checkout (order, stock and email), order history, and the admin's product and category edits. Sign-up, which raises an error today, is recorded as a known failure.
- The broken and commented-out controller specs and the placeholder mailer spec are removed; the passing `Product` model specs stay.
- The suite refuses to run against any database that isn't a test database, since `.env` on the Mac still points at the old production server.
- GitHub Actions runs the suite on every pull request and push to `master`, on Ruby 2.6.7 and PostgreSQL 18, and `master` requires it to pass before a merge.
- `README.md` shows how to run the suite locally with Docker.
- No app code, gem or image change.

## Capabilities

### New Capabilities

- `ci-test-gate`: when the test suite runs, what blocks a merge, and which database it may use.

### Modified Capabilities

None.

## Impact

- New: `.github/workflows/test.yml`, `spec/requests/*`.
- Changed: `spec/rails_helper.rb` (Devise sign-in helpers, the test-database guard), `README.md`, `Gemfile.lock` (adds the `x86_64-linux` platform so Linux runs don't rewrite it; no gem versions change).
- Removed: `spec/controllers/*`, `spec/mailers/user_mailer_spec.rb`, `spec/support/auth_helper.rb`.
- GitHub: a branch protection rule on `master` requiring the `test` check.
- Out of scope: fixing what the specs find (sign-up, admin pages that anyone can open); each is its own change.
