# Proposal

## Why

The routes and `CategoriesController` actions for listing, adding, renaming and deleting categories exist, but the views behind them are empty files. Nothing on the admin page links to them either. So an admin can't manage categories in the browser, and the actions that do run go wrong:

- **Add and delete show a blank page.** `create` and `destroy` neither redirect nor render, so the browser gets an empty response. Delete also says "Category successfully updated!".
- **Rename sends the admin to the storefront** instead of back to the categories.
- **A blank name is accepted.** The model checks only that names are unique, so one category with an empty name can be saved, and it shows up as an empty link in the navigation menu.

## What Changes

- `/categories` becomes the admin's category list:
  - it shows every category by name, with Edit and Delete buttons and an Add Category button;
  - the admin page gets a Categories button that leads there;
  - it is now admin-only. Nothing in the storefront links to it, and it was an empty page until now.
- The add and edit pages get a name form. They use the same layout as the product forms.
- Adding, renaming and deleting a category return to the category list, with a message saying what happened.
- A blank or already-used name is refused: the form shows again with an error, and nothing is saved.
- Deleting a category takes it off its products. The products themselves stay.
- Category names are stored in lowercase, so "Stouts" and "stouts" count as the same name. The pages show them with each word capitalized, which keeps today's names looking exactly as they do now.
- A migration lowercases the existing names.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `admin-access`: the category list joins the admin-only pages.
- `product-catalog`: adds how admins list, add, rename and delete categories, that a category needs a non-blank name that no other category has in any capitals, and that names are stored in lowercase and shown capitalized.

## Impact

- Changed:
  - `app/controllers/categories_controller.rb` and `app/models/category.rb`;
  - `app/views/categories/index.html.haml`, `new.html.haml`, `edit.html.haml` and `show.html.haml`;
  - `app/views/admin/index.html.haml`;
  - the places that show a category name: `app/views/layouts/application.html.haml`, and `app/views/products/show.html.haml`, `new.html.haml` and `edit.html.haml`;
  - `app/assets/stylesheets/styles/products_controller.scss`;
  - a new migration in `db/migrate`, and `db/schema.rb`;
  - `spec/requests/admin_spec.rb`, `spec/requests/admin_access_spec.rb` and `spec/views_spec.rb`.
- Production: one image rebuild and restart, plus `db:migrate`, which the README's deploy steps don't run. That makes one write to the five category rows. Rolling back means migrating down first, then going back to the old image. Any existing category with a blank name keeps working; it only has to get a name the next time it is saved.
- Out of scope: the public category page's product listing, and names that need capitals inside a word (an acronym such as "IPA" shows as "Ipa").
