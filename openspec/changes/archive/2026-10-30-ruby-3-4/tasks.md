# Tasks

## 0. Branch

- [x] 0.1 Create `ruby-3-4` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. The suite on Ruby 3.4.12

- [x] 1.1 Show the failure: run today's code in a `ruby:3.4.12` container (natively, with nodejs) against `postgres:18`. Bundler 2.2.19 crashes, and with Bundler 2.6.9, boot fails on `base64`.
- [x] 1.2 Make the code work on Ruby 3.4.12:
  - **Gemfile:** add `base64`, `bigdecimal`, `mutex_m` and `drb`, and remove `factory_girl_rails`.
  - **Lockfile:** `bundle update nokogiri --conservative`, `bundle update --bundler=2.6.9`, and `bundle lock --add-platform x86_64-linux aarch64-linux`.
  - **Specs:** switch the 5 `Faker::Number.between(1,20)` calls (4 in `spec/models/product_spec.rb`, 1 in `db/seeds.rb`) to `between(from: 1, to: 20)`.

  Verify:
  - the suite passes, 31 examples with 0 failures;
  - the lockfile diff changes no gem versions other than Nokogiri and its direct dependencies, the four added gems, `factory_girl` and `factory_girl_rails` (removed), and Bundler;
  - `concurrent-ruby` is still 1.2.3.
- [x] 1.3 Update the README's "Running the tests" section:
  - use `ruby:3.4.12`;
  - drop `--platform linux/amd64`, the `archive.debian.org` line and the Bundler install;
  - update the explanatory text.

  Verify by running the commands exactly as written, from a clean database and gem volume: they pass with 31 examples and 0 failures, and leave `Gemfile.lock` unchanged.
- [x] 1.4 Update `.github/workflows/test.yml`: use the `ruby:3.4.12` container, drop the archive line and the Bundler install, and keep `apt-get install nodejs`. Verify `actionlint` is clean.

## 2. Production image

- [x] 2.1 Update the Dockerfile:
  - `FROM ruby:3.4.12`;
  - drop the `archive.debian.org` line and `gem install bundler`;
  - replace `bundle install --without development test` with `ENV BUNDLE_WITHOUT="development test"` and `bundle install`.

  Verify on the Mac:
  - the build completes as `linux/amd64`;
  - `rails s` in the image, with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema, serves `/` with 200, `/admin` with 302 to sign-in, and the stylesheet the home page links with 200;
  - `ruby -v` in the image prints 3.4.12.

  Remove the image and containers afterwards.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `ruby-3-4`, then archive this change (syncing the modified `ci-test-gate` requirement into `openspec/specs/`) as a second commit, `Archive ruby-3-4`, and open one PR. The required `test` check must pass on Ruby 3.4.12.
- After merge, with the owner's approval, deploy on the app host with the README's steps, then run the Migration Plan's checks:
  - the container shows Ruby 3.4.12;
  - the pages and stylesheet return 200, and `/admin` redirects to sign-in;
  - the owner signs in, uses the cart, checks out and edits a product as an admin.
- Next change: Rails 6.1 to 7.0.
