# Tasks

## 0. Branch

- [x] 0.1 Create `test-baseline` from a freshly fetched `origin/master`, and check with `git status` that you're on that branch and this change's artifacts came along.

## 1. Running the suite locally, safely

- [x] 1.1 Add a "Running the tests" section to `README.md`: a Docker network, a throwaway `postgres:18`, and `ruby:2.6.7` as `linux/amd64` with the project mounted, apt pointed at `archive.debian.org`, `nodejs`, Bundler 2.2.19, `db:create db:schema:load` and `rspec`, with `DATABASE_URL` naming `shoppe_test`. Verify by running the commands exactly as written: they reproduce today's result (20 examples, 15 failures, 1 pending).
- [x] 1.2 Show the missing guard: run the suite as in 1.1 but with `DATABASE_URL` naming a scratch database `crabazon` on the throwaway server, and see it run and clean that database. Add the guard to `spec/rails_helper.rb` right after the environment loads (abort unless the database name ends in `_test`, with a one-line why comment) and `DatabaseCleaner.allow_remote_database_url = true` after it. Verify the same run now stops before any example with the guard's message, and the 1.1 run still works without `DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL`; drop that variable from the README if 1.1 used it.

## 2. Specs for how the shop works today

- [x] 2.1 Delete `spec/controllers/`, `spec/mailers/user_mailer_spec.rb` and `spec/support/auth_helper.rb`, and include `Devise::Test::IntegrationHelpers` for request specs in `rails_helper.rb`. Verify the suite runs green with only the 4 `Product` model specs.
- [x] 2.2 `spec/requests/storefront_spec.rb`: the home page lists products cheapest first, a category page shows its products, a product page shows the product. Verify it passes, and fails when one expected value is changed.
- [x] 2.3 `spec/requests/cart_spec.rb`: adding a product (as XHR JSON) returns the cart, its total and the quantity left; adding it again counts 2; updating the quantity changes the total; removing it empties the cart. Verify it passes, and fails when one expected value is changed.
- [x] 2.4 `spec/requests/sessions_spec.rb`: a customer signs in and lands on the index page, an admin lands on `/admin`, a wrong password is refused; sign-up is a `pending` example naming the `devise_parameter_sanitizer.for` error. Verify it passes with the sign-up example reported as pending.
- [x] 2.5 `spec/requests/orders_spec.rb`: a signed-in customer with a cart checks out; one order with the cart's total, one line per product, stock goes down by the quantities, one email goes to the customer, the cart is empty and the response redirects to the order; the order history lists only that customer's orders. Verify it passes, and fails when one expected value is changed.
- [x] 2.6 `spec/requests/admin_spec.rb`, signed in as an admin: `/admin` lists products; creating a product with categories, updating its quantity and deleting it each redirect to `/admin` and change the database; creating and renaming a category work. Verify it passes, and fails when one expected value is changed.

## 3. CI

- [x] 3.1 Add `.github/workflows/test.yml`: a `test` job on pull requests to `master` and pushes to `master`, in a `ruby:2.6.7` container with a `postgres:18` service, running the steps from 1.1. Verify `actionlint` is clean and a local run of the same steps passes.

## 4. Verify

- [x] 4.1 Run the full suite as the README says and verify it passes with exactly one pending example (sign-up).

## 5. Review

- [x] 5.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `test-baseline`, then archive this change (syncing `ci-test-gate` into `openspec/specs/`) as a second commit, `Archive test-baseline`, and open one PR.
- Check the PR's `test` job passes. Push a temporary commit that fails one example, see the job fail, then revert it.
- With the owner's approval, require the `test` check on `master` with `gh api` branch protection, and verify the PR shows it as required.
- Next changes: fix the open admin pages (anyone can edit products today) and sign-up; then the Ruby step of the upgrade.
