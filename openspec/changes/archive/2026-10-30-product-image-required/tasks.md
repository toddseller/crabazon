# Tasks

## 0. Branch

- [x] 0.1 Create `product-image-required` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Every product has an image

- [x] 1.1 Add the failing tests:
  - in `spec/models/product_spec.rb`, a product without an image has the error "Product image can't be blank";
  - in `spec/requests/admin_spec.rb`, an admin's create with a blank image creates nothing and shows the form with "Opps! Something went wrong";
  - an update that blanks the image leaves it unchanged and shows the same message.

  (The two products in "orders product by created_at date" already have an image.) In `spec/rails_helper.rb`'s `before(:suite)`, call `Rails.application.reload_routes_unless_loaded` first, so request specs that sign in can run on their own; without it, `spec/requests/admin_spec.rb` alone fails in `sign_in` with "Could not find a valid mapping", on `master` too. Run the specs with the README's commands and show the three new examples fail for the right reasons.
- [x] 1.2 Add `:product_image` to `Product`'s presence validation, and set `flash.now[:error] = "Opps! Something went wrong. Try again!"` in `ProductsController#update`'s failure branch. Give the products created in `cart_spec.rb`, `orders_spec.rb`, `passwords_spec.rb` and `registrations_spec.rb` an image, since the validation now refuses them. Run the whole suite; it passes.

## 2. Review

- [x] 2.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `product-image-required`, then archive this change (with spec sync, creating `product-catalog`) as a second commit, `Archive product-image-required`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's check.
