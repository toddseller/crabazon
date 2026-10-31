## ADDED Requirements

### Requirement: Changes need a CSRF token
Every request that changes something (a form post, an AJAX call, a delete) SHALL carry a valid CSRF token from the shop's own pages, or be refused with nothing changed. The shop's own forms and AJAX calls SHALL always send it.

#### Scenario: Sign-in without a token
- **WHEN** a sign-in is posted without a CSRF token
- **THEN** it is refused, and no one is signed in

#### Scenario: Checkout form submitted by the browser
- **WHEN** a customer submits the checkout form without JavaScript, for example by pressing Enter in a quantity box
- **THEN** the form carries a CSRF token, so the order is placed
