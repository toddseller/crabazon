# Proposal

## Why

The product forms list categories as checkboxes named `category_ids[]`. When none is ticked, the browser sends no `category_ids` at all, and the controller mishandles that both ways:

- **Create crashes.** `ProductsController#create` saves the product, then runs `params[:category_ids].each`, which is `nil.each`. The admin gets a 500, and the product has already been saved, without categories.
- **Update can't clear categories.** `update` copies `params[:category_ids]` into the product params. When it's missing, the copy is `nil`, strong parameters drop it, and the product keeps its old categories. So unticking every box silently does nothing.

## What Changes

- The product's categories come from the ticked boxes in one place, `product_params`, with none ticked meaning no categories. Both create and update assign them through the product, so the create loop and update's copy into `params` are deleted.
- Creating a product with no category ticked works, and the product appears on the home page under no category.
- Unticking every category on edit removes them all.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `product-catalog`: adds that a product's categories are exactly the ones ticked, none included.

## Impact

- Changed: `app/controllers/products_controller.rb`, `spec/requests/admin_spec.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations.
- Out of scope: the admin JavaScript and order email's unescaped image URLs, noted in the previous change.
