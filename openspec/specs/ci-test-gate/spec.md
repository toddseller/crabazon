# ci-test-gate Specification

## Purpose

Defines how changes to crabazon are verified before they reach `master`, which production deploys from: when the test suite runs, what blocks a merge, and which database a test run may use.

## Requirements

### Requirement: The suite runs on every pull request and push to master
The full test suite SHALL run automatically for every pull request that targets `master`, on each new commit pushed to it, and for every push to `master`.

#### Scenario: Pull request opened
- **WHEN** a pull request targeting `master` is opened or receives a new commit
- **THEN** a test run starts for its latest commit and its result is shown on the pull request

#### Scenario: Push to master
- **WHEN** a commit lands on `master`
- **THEN** a test run starts for that commit

### Requirement: A failing suite blocks the merge
A pull request into `master` SHALL NOT be mergeable until the test run for its latest commit has passed.

#### Scenario: Failing test
- **WHEN** any example in the suite fails or errors on the pull request's latest commit
- **THEN** the pull request cannot be merged

#### Scenario: Passing run
- **WHEN** the test run for the latest commit passes
- **THEN** the test requirement no longer blocks the merge

### Requirement: Tests run on production's versions
Each test run SHALL use the Ruby version the production image runs and the PostgreSQL major version production's database runs.

#### Scenario: Versions in a test run
- **WHEN** a test run starts
- **THEN** it runs Ruby 3.4.12 against PostgreSQL 18

### Requirement: Tests never touch a non-test database
The suite SHALL refuse to start when the database it would connect to is not a test database, whatever `DATABASE_URL` or `.env` configures, so a test run can never truncate production data.

#### Scenario: Production URL in the environment
- **WHEN** the suite starts with `DATABASE_URL` naming a database whose name does not end in `_test`
- **THEN** it stops before any example runs or any table is cleaned, and says why

#### Scenario: Test database
- **WHEN** the suite starts against a database whose name ends in `_test`
- **THEN** it runs normally
