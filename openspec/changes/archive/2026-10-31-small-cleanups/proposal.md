# Proposal

## Why

Three small leftovers from earlier changes:
- **Admin product table:** on `/admin`, the header underline stops partway across. The header row has 4 cells, but each product row has 6: image, name, price, quantity, Edit and Delete.
- **README deploy steps:** they don't run migrations, so the category-admin-views deploy needed a step that only its PR mentioned. The next change with a migration could miss it.
- **Compose `version:` line:** every `docker compose` command warns that the `version: "3.8"` line is obsolete and ignored.

## What Changes

- The admin product table's header gets two empty cells, matching the category list.
- The README's deploy steps run `docker compose run --rm web bin/rails db:migrate` between the build and the restart. It does nothing when no migration is pending, so it can run on every deploy. The rollback steps say to roll back a migration first, while the new image is still running.
- `version: "3.8"` is deleted from `docker-compose.yml`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. Nothing the shop does changes.

## Impact

- Changed: `app/views/admin/index.html.haml`, `spec/requests/admin_spec.rb`, `README.md`, `docker-compose.yml`.
- Production: one image rebuild and restart, with the README's rollback. No migrations.
- Out of scope: Puma, `rails_12factor` and sign-up enumeration, which each get their own change if wanted.
