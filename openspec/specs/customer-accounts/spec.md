# customer-accounts Specification

## Purpose

Defines how visitors become customers: signing up for an account, what a new account starts with, and what sign-up can never grant.

## Requirements

### Requirement: Visitors can sign up
A visitor who submits a name, an email address not already in use, a password of at least 6 characters and a matching confirmation SHALL get a customer account. They SHALL be signed in, land on the index page with an empty cart, and be sent a welcome email.

#### Scenario: Successful sign-up
- **WHEN** a visitor submits the sign-up form with a name, an unused email and a valid, confirmed password
- **THEN** an account with that name and email exists, the visitor is signed in and sent to the index page, the page shows with an empty cart, and one welcome email goes to that address

### Requirement: Invalid sign-ups create nothing
A sign-up with an email already in use, a password shorter than 6 characters or a confirmation that doesn't match SHALL NOT create an account, sign anyone in or send email. The form SHALL show again with the reason.

#### Scenario: Email already in use
- **WHEN** a visitor signs up with the email of an existing account
- **THEN** no account is created, no email is sent, and the form shows that the email has already been taken

#### Scenario: Confirmation doesn't match
- **WHEN** a visitor signs up with a confirmation different from the password
- **THEN** no account is created, no email is sent, and the form shows that the confirmation doesn't match

### Requirement: Sign-up never grants admin
An account created through sign-up SHALL be a customer account, whatever extra fields the request carries.

#### Scenario: Role sent with the form
- **WHEN** a sign-up request also carries `role=admin`
- **THEN** the account is created without the admin role, and its user is refused the admin page

### Requirement: Customers can reset a forgotten password
A visitor who asks for a password reset with the email of an account SHALL be sent one email, from the shop's sender, with a link to the shop's own address that lets them choose a new password. After choosing one through that link, they SHALL be signed in with an empty cart and land on the index page (an admin on the admin page), which SHALL show normally, and SHALL be able to sign in with the new password and no longer with the old one.

#### Scenario: Reset through the emailed link
- **WHEN** a visitor asks for a reset with an account's email, opens the emailed link, and submits a new, confirmed password from that page
- **THEN** one email went to that address from `crabazon@toddseller.com`, its link points at the shop's address, the visitor lands signed in on the index page, which shows with an empty cart, and the account signs in with the new password but not the old one

#### Scenario: Links point at the public shop
- **WHEN** the shop runs in production and sends a reset email
- **THEN** the email's link starts with `https://crabazon.us/`
