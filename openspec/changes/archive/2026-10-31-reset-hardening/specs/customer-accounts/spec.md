## MODIFIED Requirements

### Requirement: Customers can reset a forgotten password
A visitor who asks for a password reset with the email of an account SHALL be sent one email, from the shop's sender, with a link to the shop's own address that lets them choose a new password. Any visitor who asks for a reset with any address SHALL see the same page, which names the address and says a link was sent if an account uses it.

#### Scenario: Reset email sent
- **WHEN** a visitor asks for a reset with an account's email
- **THEN** one email goes to that address from `crabazon@toddseller.com`, its link points at the shop's address, and the visitor lands on the page naming that address, not on the sign-in page

#### Scenario: Links point at the public shop
- **WHEN** the shop runs in production and sends a reset email
- **THEN** the email's link starts with `https://crabazon.us/`

#### Scenario: Address with no account
- **WHEN** a visitor asks for a reset with an address that has no account
- **THEN** no email is sent, and the visitor lands on the same page as for an account's address, naming the address they typed

## ADDED Requirements

### Requirement: Reset requests are limited per address
The shop SHALL accept at most 5 reset requests for the same email address, ignoring case and surrounding spaces, within one hour. Further requests for that address SHALL send nothing, and SHALL show a message to try again later. The limit SHALL apply the same way to addresses with and without an account.

#### Scenario: Sixth request in an hour
- **WHEN** a visitor asks for a reset for the same account's address 6 times within an hour
- **THEN** the first 5 each send an email, and the sixth sends none and shows a message to try again later

#### Scenario: Other addresses are unaffected
- **WHEN** one address has reached the limit and a visitor asks for a reset for a different account's address
- **THEN** that email is sent
