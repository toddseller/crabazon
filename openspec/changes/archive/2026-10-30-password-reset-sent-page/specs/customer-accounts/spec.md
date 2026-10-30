## MODIFIED Requirements

### Requirement: Customers can reset a forgotten password
A visitor who asks for a password reset with the email of an account SHALL be sent one email, from the shop's sender, with a link to the shop's own address that lets them choose a new password, and SHALL then see a page confirming that the link was sent to that address.

#### Scenario: Reset email sent
- **WHEN** a visitor asks for a reset with an account's email
- **THEN** one email goes to that address from `crabazon@toddseller.com`, its link points at the shop's address, and the visitor lands on a page that says the link was sent to that address, not on the sign-in page

#### Scenario: Links point at the public shop
- **WHEN** the shop runs in production and sends a reset email
- **THEN** the email's link starts with `https://crabazon.us/`

## ADDED Requirements

### Requirement: A reset signs the customer in with the new password
After choosing a new password through the emailed link, the customer SHALL be signed in with an empty cart and land on the index page (an admin on the admin page), which SHALL show normally. The account SHALL then sign in with the new password and no longer with the old one.

#### Scenario: New password set through the link
- **WHEN** a visitor opens the emailed link and submits a new, confirmed password from that page
- **THEN** they land signed in on the index page, which shows with an empty cart, and the account signs in with the new password but not the old one
