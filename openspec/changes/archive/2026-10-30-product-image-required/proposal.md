# Proposal

## Why

A product's image is optional today, and every page that lists products assumes it's there:
- The admin list, the product page and the order pages call `image_tag` on it, which raises on `nil` and turns the page into a 500 for everyone. This happened in a production-mode test run on October 30, with a product created without an image.
- The storefront, category pages and the order email put it straight into an `<img src>`, which shows a broken image when it's blank.

Through the admin form, an empty field arrives as `""`. `image_tag("")` doesn't raise, so an admin gets a broken image rather than a crash. Products created another way (console, seeds) can be `nil` and crash the pages. All 15 products in production have an image today.

## What Changes

- A product needs an image URL to be saved, as it already needs a name, description, price and quantity. The admin form refuses a blank one and says why.
- **Found while applying:** `spec/rails_helper.rb` loads the routes before the suite (`Rails.application.reload_routes_unless_loaded`). Since Rails 8.1, routes in the test environment load on the first request, and Devise builds its user mapping only then. So a spec file run on its own fails in `sign_in` with "Could not find a valid mapping", on `master` too. The full suite only passes because an earlier file happens to make a request first.
- A failed product update now shows the same "Opps! Something went wrong" message that a failed create shows. Today an update that doesn't save just shows the form again, with no message.

## Capabilities

### New Capabilities

- `product-catalog`: what a product must have to be saved.

### Modified Capabilities

None.

## Impact

- Changed:
  - `app/models/product.rb`, `app/controllers/products_controller.rb`;
  - `spec/models/product_spec.rb`, `spec/requests/admin_spec.rb`, `spec/rails_helper.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations. No existing product is affected.
- Out of scope, found while reading the code:
  - creating a product with no category ticked raises `NoMethodError` (`nil.each` in `ProductsController#create`);
  - the admin JavaScript and the order email build image tags from the URL by string concatenation, or without quoting the attribute. Only admins set the URL.
