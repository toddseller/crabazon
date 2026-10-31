# Tasks

## 0. Branch

- [x] 0.1 Create `product-without-category` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Categories come from the ticked boxes

- [x] 1.1 In `spec/requests/admin_spec.rb`, add the failing tests:
  - creating a valid product with no `category_ids` redirects to `/admin` and leaves it in no category;
  - updating a product in a category with no `category_ids` leaves it in no category;
  - an update with a blank image and a different category leaves both the image and the categories unchanged.

  Run them with the README's commands and show the first two fail for the right reasons: `nil.each` on create, and the old category still there on update.
- [x] 1.2 Change `product_params` to merge `category_ids: params[:category_ids] || []`. Delete the loop and `@categories_id` from `create`, and the copy into `params[:product]` and `@categories_id` from `update`. Run the whole suite; it passes.

## 2. Review

- [x] 2.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `product-without-category`, then archive this change (with spec sync into `product-catalog`) as a second commit, `Archive product-without-category`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's check.
