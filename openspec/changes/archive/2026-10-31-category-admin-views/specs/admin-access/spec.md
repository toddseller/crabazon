## MODIFIED Requirements

### Requirement: Only admins manage the catalog
The admin page, the category list, and every page or request that creates, edits, updates or deletes a product or a category, SHALL be available only to a signed-in user whose role is admin. For anyone else the request SHALL change nothing in the database.

#### Scenario: Anonymous visitor
- **WHEN** a visitor who is not signed in opens the admin page, the category list or a product or category form, or sends a product or category create, update or delete
- **THEN** they are sent to the sign-in page and no product or category changes

#### Scenario: Signed-in customer
- **WHEN** a signed-in user who is not an admin opens the admin page, the category list or a product or category form, or sends a product or category create, update or delete
- **THEN** they are sent to the home page with a message saying the page is for admins, and no product or category changes

#### Scenario: Admin
- **WHEN** a signed-in admin opens the admin page or the category list, or creates, updates or deletes a product or category
- **THEN** it works as before
