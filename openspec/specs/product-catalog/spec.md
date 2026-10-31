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
