# Design

## Context

See proposal.md, Why. Everything the category pages need already exists: the `resources :categories` routes, the `CategoriesController` actions and `category_params`, and the admin guard (`authenticate_admin!`, applied to everything except `index` and `show`). The product admin pages set the look: the logo, a heading, the `#flash` boxes, Bootstrap 3 `form-horizontal` forms and a striped table with Edit and Delete buttons.

## Goals / Non-Goals

**Goals:** fill the three empty views; make each action end on the category list; refuse blank names; store names in lowercase and show them capitalized.

**Non-Goals:**
- new routes or a separate admin namespace;
- changing how products pick their categories;
- changing what the public category page and the navigation menu list, beyond how names look.

## Decisions

### `/categories` is the admin list, guarded like the rest

`before_action :authenticate_admin!, except: [:show]`.
- **Why:** the index view is empty today, and nothing in the storefront links to it, so nobody loses a page.
- **Alternative rejected:** listing categories on `/admin` under the products. That mixes two tables on one page and still leaves the empty index route showing a blank page.

### One form partial for add and edit

`new.html.haml` and `edit.html.haml` each render `_form.html.haml` with their own heading. The form has one field, so two copies of it would only be two places to change.
- **Submit labels:** `f.submit` gives "Create Category" or "Update Category" without being told.
- **Edit heading:** it uses `@category.name_was`, so a refused rename still shows the category's real name.
- **Alternative rejected:** separate full forms, like the products have. The product forms differ in the image preview and the ticked categories; the category forms would not differ at all.

### Every action ends on the list

`create`, `update` and `destroy` set `flash[:success]` and `redirect_to categories_path`. A refused save uses `flash.now[:error]` with the shop's existing "Opps! Something went wrong. Try again!" and renders the form. That is what `ProductsController` does, including the 200 status, so the two admin areas behave the same.

### Names are lowercased in the model, and capitalized by CSS

- **Model:** `normalizes :name, with: ->(name) { name.strip.downcase }`, then `validates :name, presence: true, uniqueness: true`.
  - Rails applies `normalizes` before validation and to `find_by` lookups. The existing uniqueness check therefore already ignores case, with no `case_sensitive: false` and no SQL `lower()`.
  - `presence` is needed because a uniqueness check alone lets one empty name through.
- **Pages:** each place that prints a category name wraps it in `.category-name`, and `styles/products_controller.scss` gives that class `text-transform: capitalize`. Those places are the menu, the product page links, the category page heading, the admin list and the product form checkboxes. The CSS changes only how the name looks; the page text stays lowercase.
- **Checkbox summary:** the product form's `.multiSel` gets the same class, since `admin.js` copies the ticked names into it.
- **Category page heading:** it becomes `Welcome to <span class="category-name">…</span>!`, so only the name is capitalized and not "Welcome To".
- **Alternative rejected:** capitalizing in Ruby, with `titleize` in a helper. That is a helper call in every view, and `titleize` also rewrites underscores and dashes. CSS does the job in one rule.

### A migration lowercases the existing rows

A new migration runs `UPDATE categories SET name = lower(trim(name))`, and goes down with `initcap(name)`.
- **Live names:** the five live names are title case, with `&` and commas, so `initcap` gives back exactly what is there today.
- **Collisions:** none. No two live names differ only by case, so nothing breaks the uniqueness rule.
- **The deploy:** it gets one extra step, `docker compose run --rm web bin/rails db:migrate`, after the build and before `up -d`.

### Delete relies on the join table

Destroying a `has_and_belongs_to_many` record deletes its `categories_products` rows, so its products lose the category and stay. The Delete button uses jquery_ujs's `method: :delete` with a `data-confirm`, like product Delete, and Rails adds the CSRF token.

## Risks / Trade-offs

- **[Existing blank names]** I couldn't count production categories, because the read-only query was not approved. If one exists, it keeps working, but it can't be saved again without a name. → Mitigation: the owner sees it in the new list and can rename it.
- **[Delete is one click past a confirm]** Deleting a category removes it from every product, and nothing brings that back. → Mitigation: the same confirm dialog that guards product Delete.
- **[Acronyms]** `capitalize` only raises the first letter of each word, so "IPA" would show as "Ipa". → No live name needs inner capitals. A name that does would need a different approach, and that is out of scope.
- **[Rollback order]** The old image shows names exactly as stored, so going back to it after the migration shows them in lowercase. → Roll back with `db:rollback` first, then the old image.
- **[Copy and paste]** Some browsers copy the stored lowercase text rather than what's shown. → Harmless for a menu.

## Migration Plan

1. Deploy with the README's steps, plus `docker compose run --rm web bin/rails db:migrate` between the build and `up -d`. Sessions are kept.
2. Owner checks:
   - the menu shows the same five names as before;
   - open Categories from the admin page;
   - add a test category and see it in the navigation menu;
   - rename it;
   - delete it, and check that it leaves the menu and its products are still there.
3. Rollback, in this order:
   1. `docker compose run --rm web bin/rails db:rollback` (while the new image is still current);
   2. the README's `crabazon-web:previous` steps.

   Categories added in the meantime stay, title-cased by `initcap`.
