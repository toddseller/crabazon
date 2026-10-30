# Proposal

## Why

Production runs Ruby 2.6.7, which has had no security fixes since March 2022, on a Debian 10 image whose package repositories are archived. Every later Rails step needs a newer Ruby. Rails 7.2 needs 3.1 or later, and Rails 8 needs 3.2 or later. Moving Ruby first, with Rails left at 6.1, means the test suite pins any breakage on Ruby alone.

## What Changes

- **Ruby:** production, CI and the README's local test runs all move from Ruby 2.6.7 to 3.4.12. Ruby 3.4 is supported until about March 2028. The image base becomes `ruby:3.4.12` (Debian 13), so the `archive.debian.org` workaround goes.
- **Gems Ruby 3.4 stopped bundling:** Rails 6.1 needs `base64`, `bigdecimal`, `mutex_m` and `drb` loaded, and Ruby 3.4 no longer ships them as default gems, so they are added to the Gemfile.
- **Removed:** the unused `factory_girl_rails`. It fails to load on Ruby 3.4, and nothing in the app or specs uses it.
- **Nokogiri:** updated to a release with prebuilt gems for Ruby 3.4. 1.13.10's stop at Ruby 3.1, and it has known security fixes since.
- **Bundler:** 2.2.19 to 2.6.9, the version Ruby 3.4.12 ships. 2.2.19 crashes on Ruby 3.4.
- **Lockfile platforms:** the lockfile adds the `aarch64-linux` platform, so the README's local runs on Apple silicon no longer need x86 emulation.
- **Specs:** the 5 `Faker::Number.between(1, 20)` calls (4 in `spec/models/product_spec.rb`, 1 in `db/seeds.rb`) use keyword arguments. Faker 2.22's warning for the positional form crashes on Ruby 3.4.
- **Unchanged:** Rails stays 6.1.7.7, and every other gem stays at its locked version.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `ci-test-gate`: test runs use Ruby 3.4.12, still matching production.

## Impact

- Changed:
  - `Gemfile`, `Gemfile.lock`, `Dockerfile`;
  - `.github/workflows/test.yml`;
  - the README's "Running the tests" section;
  - `spec/models/product_spec.rb` and `db/seeds.rb`.
- Production: one image rebuild and restart, with the README's rollback to the previous image.
- Out of scope:
  - the Rails upgrade steps;
  - the Ruby 4.0 warnings about `logger`, `ostruct` and `benchmark` (they're warnings, not errors, on 3.4);
  - Devise's `devise_error_messages!` deprecation;
  - trimming the image's unused apt packages.
