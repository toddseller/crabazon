# Spec Delta

## MODIFIED Requirements

### Requirement: Tests run on production's versions
Each test run SHALL use the Ruby version the production image runs and the PostgreSQL major version production's database runs.

#### Scenario: Versions in a test run
- **WHEN** a test run starts
- **THEN** it runs Ruby 3.4.12 against PostgreSQL 18
