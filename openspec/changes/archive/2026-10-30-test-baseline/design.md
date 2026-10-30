# Design

## Context

- A throwaway run on October 30 showed what the suite needs on today's stack. Bundler 2.2.19 installs every gem in `ruby:2.6.7` with no `apt-get`. Rails won't boot without a JavaScript runtime (`uglifier` loads `execjs`), and Debian 10's `nodejs` (v10) installs once apt points at `archive.debian.org`. Nokogiri's arm64 gem needs a newer glibc than Debian 10 has, so on the Mac the container must run as `linux/amd64`. DatabaseCleaner refuses a `DATABASE_URL` whose host isn't local. With all that, 4 of 20 examples pass (the `Product` model specs).
- The failing specs are controller specs written for Rails 4 (`get :edit, id:`), using `assigns` and `render_template`, which need a gem the app doesn't have, and a `reseller_id` column a migration removed.
- `.env` on the Mac still holds `DATABASE_URL` for the old production server, as a superuser, and `dotenv-rails` loads it in the test environment whenever the variable isn't already set. `ActiveRecord::Migration.maintain_test_schema!` can reload the schema, and DatabaseCleaner truncates every table.
- The app has no server-side admin check: `/admin` and the product and category writes work for anyone. Sign-up raises `NoMethodError`, because `Users::RegistrationsController` calls `devise_parameter_sanitizer.for`, which Devise 4 removed.

## Goals / Non-Goals

**Goals:**
- A suite that passes on today's stack and fails when a later step changes how the shop behaves.
- CI on every pull request and push to `master`, required for merging.

**Non-Goals:**
- Fixing sign-up, the open admin pages or anything else the specs find.
- Gem changes (`factory_girl` to `factory_bot`, `rails-controller-testing`); the upgrade changes gems.
- Browser (JavaScript) tests. The cart's XHR endpoints are tested at the HTTP level.
- Caching gems in CI; add it if runs get slow.

## Decisions

1. **Request specs, not controller specs.** They exercise routing, controllers, views and the session together, and they survive the Rails upgrade, while controller specs with `assigns` don't without an extra gem. Records are built with plain `create!` and fixed values; no factory gem is added, since `factory_girl` is on its way out.

2. **Characterize, don't correct.** Each spec asserts what the shop does today. Sign-up is a `pending` example: it fails today, so it passes as pending, and once sign-up is fixed RSpec reports the pending example as passing, so the marker has to come off. Admin flows sign in as a user whose `role` is `admin`; no spec asserts that anonymous users can reach them, so fixing that later doesn't break the suite.

3. **Guard in `rails_helper.rb`, right after the environment loads:** abort unless `ActiveRecord::Base.connection_db_config.database` ends in `_test`. It runs before `maintain_test_schema!` and before any cleaning, and it checks the database name, which a test database always has here (`shoppe_test`), not the host. With that guard in place, `DatabaseCleaner.allow_remote_database_url = true` lets CI's database service host through without an environment variable.

4. **CI: one `test` job in a `ruby:2.6.7` container on GitHub's amd64 runners, with a `postgres:18` service.** The job points apt at `archive.debian.org`, installs `nodejs`, installs Bundler 2.2.19 and the gems, loads `db/schema.rb` and runs `rspec`. Alternative: `ruby/setup-ruby` on the runner itself; the container matches the production image's Debian 10 and libpq 11 instead.

5. **Local runs use the same container,** with the project mounted, `--platform linux/amd64`, and a throwaway `postgres:18` on a Docker network. The README gives the commands. It's slow under emulation; the upgrade's later steps move the suite to the Mac's own Ruby.

6. **Branch protection on `master` requires the `test` check,** set with `gh api` after the workflow has run once, so GitHub knows the check's name.

## Risks / Trade-offs

- [`archive.debian.org` goes away or changes] → CI fails at the Node install; the Ruby upgrade replaces Debian 10 soon, and the error is loud.
- [Specs that encode today's bugs make fixes look like regressions] → known bugs are `pending` or left unasserted (decision 2).
- [Session-based cart specs depend on cookie handling in request specs] → request specs keep cookies between requests in one example; each cart spec does all its steps in one example.
- [Order email delivery fails in tests] → the test environment uses `delivery_method = :test`; the checkout spec asserts the email in `ActionMailer::Base.deliveries`.

## Migration Plan

Merge like any change. The first push runs the workflow; after it passes, add branch protection (with the owner's approval). Nothing deploys: specs, CI and the README don't reach the app host's container.
