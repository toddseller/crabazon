## ADDED Requirements

### Requirement: Product and category text is never markup
A product's name and image URL, and a category's name, SHALL be shown as text or as a single attribute value wherever the shop displays them: pages, the cart, the admin forms and emails. A value containing HTML, quotes or spaces SHALL NOT add elements or attributes.

#### Scenario: Name with HTML in the cart
- **WHEN** a product is named `<img src=x onerror=alert(1)>` and a customer opens their cart
- **THEN** the cart shows that name as text, and no script runs

#### Scenario: Image URL with a quote or a space
- **WHEN** a product's image URL contains `"` or a space followed by an attribute, and an order email lists it, or the cart shows it
- **THEN** the image's `src` is the whole URL, and the tag gains no other attributes
