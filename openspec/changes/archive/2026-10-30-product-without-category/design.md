# Design

## Context

- **Forms:** `products/new` and `products/edit` render each category as `%input{type: 'checkbox', name: 'category_ids[]'}`, outside the `product` params. A browser sends no key for an unticked checkbox, so with none ticked, `params[:category_ids]` is `nil`.
- **`create`:**
  - `Product.new(product_params)` and `save`;
  - then `params[:category_ids].each { Category.find(id) ... @product.categories << category }`;
  - with none ticked, `nil.each` raises after the save, so the product exists without categories and the admin sees a 500.
- **`update`:**
  - `params[:product][:category_ids] = params[:category_ids]`, then `@product.update(product_params)`, where `product_params` permits `category_ids: []`;
  - a `nil` there isn't an array, so strong parameters drop it, and the categories stay as they were.
- **Failed saves:** `ApplicationController#set_categories` sets `@categories` before every action, so a failed create or update can render its form.
- **Tests:** `spec/requests/admin_spec.rb` always ticks a category, so neither path is covered.

## Goals / Non-Goals

**Goals:**
- Creating with no category works.
- Unticking every category clears them.
- One place decides a product's categories.

**Non-Goals:**
- Requiring at least one category. Products in no category still show on the home page.
- Changing the forms.

## Decisions

1. **Build categories in `product_params`:** `params.require(:product).permit(:name, :description, :price, :quantity, :product_image).merge(category_ids: params[:category_ids] || [])`. Assigning `category_ids` sets a `has_and_belongs_to_many` association on a new record when it's saved, and replaces it on an existing one.
   - `create` becomes `Product.new(product_params)` plus `save`. The loop goes, and so does `@categories_id`.
   - `update` loses its copy into `params`.
   - An unknown id raises `ActiveRecord::RecordNotFound`, as `Category.find` did.
   - Alternative: `|| []` in each action. That leaves two places to keep in step, plus the loop.
2. **Failed updates leave categories alone.** `update` assigns and saves inside one transaction, so a refused update, such as a blank image, rolls back the category change too. A request spec covers it.

## Risks / Trade-offs

- [`category_ids` outside `product` isn't filtered by strong parameters] → It goes only into `category_ids=`, which looks up categories by id. Only admins reach these actions. A malformed value fails the lookup, as `Category.find` did before.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check: the owner adds a product with no category ticked (it saves), edits it to add a category, then unticks it again.
4. Rollback: the README's rollback steps. No migrations.
