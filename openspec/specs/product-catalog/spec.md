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
