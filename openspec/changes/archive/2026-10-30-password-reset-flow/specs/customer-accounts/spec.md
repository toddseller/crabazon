## MODIFIED Requirements

### Requirement: Customers can reset a forgotten password
A visitor who asks for a password reset with the email of an account SHALL be sent one email, from the shop's sender, with a link to the shop's own address that lets them choose a new password. After choosing one through that link, they SHALL be signed in with an empty cart and land on the index page (an admin on the admin page), which SHALL show normally, and SHALL be able to sign in with the new password and no longer with the old one.

#### Scenario: Reset through the emailed link
- **WHEN** a visitor asks for a reset with an account's email, opens the emailed link, and submits a new, confirmed password from that page
- **THEN** one email went to that address from `crabazon@toddseller.com`, its link points at the shop's address, the visitor lands signed in on the index page, which shows with an empty cart, and the account signs in with the new password but not the old one

#### Scenario: Links point at the public shop
- **WHEN** the shop runs in production and sends a reset email
- **THEN** the email's link starts with `https://crabazon.us/`
