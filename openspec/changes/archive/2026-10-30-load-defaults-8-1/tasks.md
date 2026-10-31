# Tasks

## 0. Branch

- [x] 0.1 Create `load-defaults-8-1` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Rails 8.1 defaults

- [x] 1.1 Add `spec/requests/forgery_protection_spec.rb`, with forgery protection turned on around each example:
  - a sign-in posted without a token is refused, and no one is signed in;
  - for a signed-in customer with a cart, `/orders/new`'s form contains an `authenticity_token` field.

  Run it with the README's commands and show both fail: today the sign-in goes through, and the form has no token.
- [x] 1.2 Replace `config.active_support.cache_format_version = 7.1` with `config.load_defaults 8.1`, and delete `config/initializers/cookies_serializer.rb`. Run the whole suite and show the "User must exist" failures.
- [x] 1.3 Delete `belongs_to :user` from `Product` and `has_many :products, through: :orders_products` from `User`. Add `= hidden_field_tag :authenticity_token, form_authenticity_token` inside the checkout `%form`. Run the whole suite; it passes with no deprecations.

## 2. Production image

- [x] 2.1 Build the image on the Mac as `linux/amd64`, and run it with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema, an admin, a customer and a product with an image. Verify:
  - a sign-in without a token gets 422, and one with the page's token signs in;
  - with the page's `X-CSRF-Token` header, adding to the cart and checking out work, and without it they get 422;
  - posting the checkout form natively, with its hidden token, places an order;
  - an admin can create and update a product through the forms (categories have no edit form: `categories/new`, `edit` and `index` are empty views, so renaming stays a request-spec check);
  - a reset token made in `rails runner` opens the change-password page, and submitting it with the page's token sets the new password (the container can't reach the mail server, so the sending step is the owner's check after deploy);
  - a session cookie from an image built from `origin/master` is not accepted (expected: sign in again).

  Remove the images and containers.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `load-defaults-8-1`, then archive this change (with spec sync, creating `request-protection`) as a second commit, `Archive load-defaults-8-1`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps (everyone is signed out) and run the Migration Plan's checks.
