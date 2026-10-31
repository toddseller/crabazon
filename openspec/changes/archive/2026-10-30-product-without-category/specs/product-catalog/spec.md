## ADDED Requirements

### Requirement: A product's categories are the ones ticked
When an admin creates or updates a product, its categories SHALL become exactly the categories ticked on the form. Ticking none SHALL be allowed, and SHALL leave the product in no category.

#### Scenario: Create with no category ticked
- **WHEN** an admin submits a new, valid product with no category ticked
- **THEN** the product is created in no category, and the admin is sent to the admin page

#### Scenario: Untick every category
- **WHEN** an admin edits a product in a category and unticks every category
- **THEN** the product is saved in no category
