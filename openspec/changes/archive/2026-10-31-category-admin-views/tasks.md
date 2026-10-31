# Tasks

## 0. Branch

- [x] 0.1 Create `category-admin-views` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Category admin pages

- [x] 1.1 Add the failing tests:
  - in `spec/requests/admin_access_spec.rb`, add `[:get, '/categories']` to the guarded requests;
  - in `spec/requests/admin_spec.rb`:
    - `/admin` links to `/categories`;
    - `/categories` lists the categories with Edit and Delete links and links to `/categories/new`;
    - the add and edit pages have a form with a `category[name]` field;
    - creating a category redirects to `/categories`, and the list shows the success message;
    - deleting a category that has a product redirects to `/categories`, with a "deleted" message, and the product still exists without it;
    - a blank name on create, and another category's name on rename, save nothing and show the error;
    - adding "  craft BEER " saves "craft beer", and adding "STOUTS" next to an existing "stouts" is refused;
    - change the existing rename example to expect `/categories`.

  Run them with the README's commands and show they fail for the right reasons: no admin guard on the list, empty views, no redirect, and a blank name accepted.
- [x] 1.2 Write the code:
  - in the controller, guard everything except `show`, redirect `create`, `update` and `destroy` to `categories_path` with their messages, and use `flash.now` on refused saves;
  - in the model, add `normalizes :name` (strip and downcase) and `presence: true`;
  - write `index`, `new`, `edit` and a shared `_form` in the product admin's style;
  - add a Categories button to `admin/index`.

  Run the whole suite; it passes.

## 2. Existing names

- [x] 2.1 In `spec/views_spec.rb`, add a check that each view printing `category.name` or `@category.name` wraps it in `.category-name`, and show it fail. Then:
  - wrap each one, including the product forms' `.multiSel`;
  - give the class `text-transform: capitalize` in `styles/products_controller.scss`, where the admin styles live.

  Run the whole suite; it passes.
- [x] 2.2 Add the migration: up runs `UPDATE categories SET name = lower(trim(name))`, and down runs `initcap(name)`. Then update `db/schema.rb`. Check it against a throwaway `postgres:18`:
  - seed it with the five live names;
  - migrate, and see them in lowercase;
  - roll back, and see them exactly as they were.

## 3. Rendered pages

- [x] 3.1 Build the image on the Mac as `linux/amd64`, and run it with `RAILS_ENV=production` against a throwaway `postgres:18` with an admin, a category and a product in it. In headless Chrome (`zenika/alpine-chrome:124`), sign in as the admin, then:
  - open Categories from the admin page;
  - add a category;
  - rename it;
  - delete it through the confirm dialog.

  Seed the five live names through the migration first. Take screenshots of the menu, the category page heading and a product form's checkboxes, and check the names look like today's.

  Take screenshots of the list and the edit form, and check they match the product admin pages. Remove the images and containers.

## 4. Review

- [x] 4.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `category-admin-views`, then archive this change (with spec sync into `admin-access` and `product-catalog`) as a second commit, `Archive category-admin-views`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps plus `db:migrate` (a production write) and run the Migration Plan's checks.
