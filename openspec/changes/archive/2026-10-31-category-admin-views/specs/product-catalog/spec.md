## ADDED Requirements

### Requirement: Admins manage categories in the browser
The admin page SHALL link to a category list that shows every category by name. From that list an admin SHALL be able to add a category, rename one and delete one. Each of these SHALL return the admin to the list with a message saying what happened. Deleting a category SHALL take it off its products, and SHALL keep the products.

#### Scenario: Add a category
- **WHEN** an admin opens the category list, chooses Add Category and submits a new name
- **THEN** they are back on the category list, which shows the new category and a message that it was created

#### Scenario: Rename a category
- **WHEN** an admin chooses Edit for a category and submits a different name
- **THEN** they are back on the category list, which shows the new name and a message that it was updated

#### Scenario: Delete a category that has products
- **WHEN** an admin deletes a category that some products are in
- **THEN** they are back on the category list without that category and with a message that it was deleted, and the products still exist but are no longer in that category

### Requirement: A category needs a unique name
The shop SHALL refuse to save a category whose name is blank or is already used by another category, ignoring case. A refused add or rename SHALL show the form again with an error message, and SHALL change nothing.

#### Scenario: Blank name
- **WHEN** an admin submits the add form with an empty name
- **THEN** no category is created, and the form shows an error

#### Scenario: Rename to a used name
- **WHEN** an admin renames a category to the name of another category
- **THEN** the category keeps its old name, and the form shows an error

#### Scenario: Same name in other capitals
- **WHEN** a category named "Stouts" exists and an admin adds "STOUTS"
- **THEN** no category is created, and the form shows an error

### Requirement: Category names are shown capitalized
The shop SHALL store a category's name in lowercase, with spaces trimmed from both ends. Wherever it shows a category's name, it SHALL show each word starting with a capital letter.

#### Scenario: Name typed in mixed case
- **WHEN** an admin adds a category named "  craft BEER "
- **THEN** it is saved as "craft beer", and the menu, product pages, category page and admin pages show "Craft Beer"
