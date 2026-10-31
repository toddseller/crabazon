# Design

## Context

- **Model:** `Product` validates the presence of `name`, `description`, `price` and `quantity`. `product_image` is a nullable string with no validation.
- **Views:**
  - `image_tag(product.product_image)` in `admin/index`, `products/show`, `orders/show` and `orders/new`;
  - `%img{src: product.product_image}` in `index/index`, `categories/show` and the product forms;
  - `admin.js` and `user_mailer/order_email` build image tags from the URL.
- **What the form sends:** an empty text field arrives as `""`. In production, `image_tag("")` returns a tag, and `image_tag(nil)` raises "Nil location provided".
- **Controller:**
  - `create` sets `flash[:error] = "Opps! Something went wrong. Try again!"` and renders `new`, which shows `flash[:error]`;
  - `update` renders `edit` with no message, although `edit` also shows `flash[:error]`.
- **Production data:** 15 products, none with a `nil` or blank image.
- **Specs:**
  - `spec/models/product_spec.rb` "orders product by created_at date" creates two products with `Product.create` and no image, so they would stop saving;
  - the three "empty field" examples pass an image already.

## Goals / Non-Goals

**Goals:**
- No product can be saved without an image URL, so no page meets a missing one.
- The admin sees why a save failed, on create and on update.

**Non-Goals:**
- Checking that the URL is a valid image or reachable.
- Fixing the other admin-only issues listed in the proposal.

## Decisions

1. **`validates :product_image, presence: true`, added to the existing `validates` line.** Presence rejects `nil`, `""` and whitespace, so it covers the console and the form alike.
   - Alternative: a placeholder image in every view. That's eight places to change, and it hides the missing data instead of stopping it.
2. **`flash.now[:error]` in `update`'s failure branch, with the same message as `create`.** `flash.now` shows it on this render only. `create` keeps its existing `flash[:error]`; changing it is out of scope.
3. **Load the routes in `before(:suite)`,** with `Rails.application.reload_routes_unless_loaded`, the Rails 8.1 call for exactly this. Without it, `admin_spec.rb` run on its own fails in `sign_in` ("Could not find a valid mapping"), because Rails 8.1 loads routes lazily in tests and Devise registers its mapping while they load. Found while applying; it fails the same way on `master`.

## Risks / Trade-offs

- [An existing product without an image can't be edited until an image is added] → None exist in production today. The form explains it.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check: the owner tries to add a product with a blank image URL and sees the error, then edits a product as usual.
4. Rollback: the README's rollback steps. No migrations.
