# product-catalog Specification

## Purpose

Defines what a product must have before the shop will save it, so every page that shows products can rely on it.

## Requirements

### Requirement: Every product has an image
A product SHALL NOT be saved without an image URL, whether it is being created or updated. When an admin's create or update is refused for this, the form SHALL show again with a message, and nothing SHALL change.

#### Scenario: Create without an image
- **WHEN** an admin submits a new product with the image URL left blank
- **THEN** no product is created, and the form shows again with an error message

#### Scenario: Update removes the image
- **WHEN** an admin edits a product and clears its image URL
- **THEN** the product keeps its image, and the form shows again with an error message

### Requirement: A product's categories are the ones ticked
When an admin creates or updates a product, its categories SHALL become exactly the categories ticked on the form. Ticking none SHALL be allowed, and SHALL leave the product in no category.

#### Scenario: Create with no category ticked
- **WHEN** an admin submits a new, valid product with no category ticked
- **THEN** the product is created in no category, and the admin is sent to the admin page

#### Scenario: Untick every category
- **WHEN** an admin edits a product in a category and unticks every category
- **THEN** the product is saved in no category

### Requirement: Product and category text is never markup
A product's name and image URL, and a category's name, SHALL be shown as text or as a single attribute value wherever the shop displays them: pages, the cart, the admin forms and emails. A value containing HTML, quotes or spaces SHALL NOT add elements or attributes.

#### Scenario: Name with HTML in the cart
- **WHEN** a product is named `<img src=x onerror=alert(1)>` and a customer opens their cart
- **THEN** the cart shows that name as text, and no script runs

#### Scenario: Image URL with a quote or a space
- **WHEN** a product's image URL contains `"` or a space followed by an attribute, and an order email lists it, or the cart shows it
- **THEN** the image's `src` is the whole URL, and the tag gains no other attributes

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
