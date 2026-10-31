# customer-accounts Specification

## Purpose

Defines how visitors become customers: signing up for an account, what a new account starts with, and what sign-up can never grant.

## Requirements

### Requirement: Visitors can sign up
A visitor who submits a name, an unused email, a password of at least 6 characters and a matching confirmation SHALL get a customer account that can't sign in until its address is confirmed. The visitor SHALL see a page naming the address, and one email SHALL go to it with a link that confirms the account and opens the sign-in page.

#### Scenario: Successful sign-up
- **WHEN** a visitor submits the sign-up form with a name, an unused email and a valid, confirmed password
- **THEN** an unconfirmed account with that name and email exists, nobody is signed in, the visitor sees a page naming the address, and one confirmation email goes to that address

#### Scenario: Confirming the address
- **WHEN** the visitor opens the link in the confirmation email and then signs in
- **THEN** the account is confirmed, the link opens the sign-in page with a message saying so, and the sign-in lands on the index page with an empty cart

#### Scenario: Signing in before confirming
- **WHEN** someone signs in to an unconfirmed account with the right password
- **THEN** they are not signed in, and they see a message to confirm the address first

### Requirement: Invalid sign-ups create nothing
A sign-up with a password shorter than 6 characters or a confirmation that doesn't match SHALL NOT create an account, sign anyone in or send email, and SHALL show the form again with the reason. A sign-up with the email of an existing account SHALL NOT create an account or sign anyone in. No sign-up SHALL say that the email is already in use.

#### Scenario: Email already in use
- **WHEN** a visitor signs up with the email of an existing account
- **THEN** no second account is created, nobody is signed in, and nothing on the page says the email is taken

#### Scenario: Confirmation doesn't match
- **WHEN** a visitor signs up with a confirmation different from the password
- **THEN** no account is created, no email is sent, and the form shows that the confirmation doesn't match

#### Scenario: Taken email and a mismatched confirmation
- **WHEN** a visitor signs up with the email of an existing account and a confirmation different from the password
- **THEN** no account is created, no email is sent, and the form shows only that the confirmation doesn't match

### Requirement: Sign-up never grants admin
An account created through sign-up SHALL be a customer account, whatever extra fields the request carries.

#### Scenario: Role sent with the form
- **WHEN** a sign-up request also carries `role=admin`
- **THEN** the account is created without the admin role, and its user is refused the admin page

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

### Requirement: A reset signs the customer in with the new password
After choosing a new password through the emailed link, the customer SHALL be signed in with an empty cart and land on the index page (an admin on the admin page), which SHALL show normally. The account SHALL then sign in with the new password and no longer with the old one.

#### Scenario: New password set through the link
- **WHEN** a visitor opens the emailed link and submits a new, confirmed password from that page
- **THEN** they land signed in on the index page, which shows with an empty cart, and the account signs in with the new password but not the old one

### Requirement: Reset requests are limited per address
The shop SHALL accept at most 5 reset requests for the same email address, ignoring case and surrounding spaces, within one hour. Further requests for that address SHALL send nothing, and SHALL show a message to try again later. The limit SHALL apply the same way to addresses with and without an account.

#### Scenario: Sixth request in an hour
- **WHEN** a visitor asks for a reset for the same account's address 6 times within an hour
- **THEN** the first 5 each send an email, and the sixth sends none and shows a message to try again later

#### Scenario: Other addresses are unaffected
- **WHEN** one address has reached the limit and a visitor asks for a reset for a different account's address
- **THEN** that email is sent

### Requirement: A taken address looks like a new sign-up
A valid sign-up with the email of an existing account SHALL create nothing and SHALL show the same page as a new sign-up, naming the address. The owner of a confirmed account SHALL get one email saying someone tried to sign up with their address, with sign-in and reset links. An unconfirmed account's owner SHALL get the confirmation email again instead.

#### Scenario: Valid sign-up with a taken email
- **WHEN** a visitor submits a valid sign-up with the email of an existing account
- **THEN** no account is created, the visitor sees the same page as for a new sign-up, and the owner gets one notice email with sign-in and reset links

#### Scenario: Signing up again before confirming
- **WHEN** a visitor signs up with the email of an account that was never confirmed
- **THEN** no account is created, the visitor sees the same page as for a new sign-up, and the confirmation email goes to that address again

### Requirement: Account emails share the shop's design
The confirmation, taken-address and password reset emails SHALL use the shop's email design: the logo at the top, a heading, the message and an orange button for the main action, and the small logo at the bottom.

#### Scenario: Reset email design
- **WHEN** a customer asks for a password reset
- **THEN** the email shows the shop's logo, a heading and an orange button that opens the change-password page
