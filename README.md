# incentera-contracts-v1

![Foundry CI](https://github.com/81k-ltd/incentera-contracts-v1/actions/workflows/ci.yml/badge.svg) [![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

**DISCLAIMER: This code has NOT been externally audited and is actively being developed. Please do not use in production without taking the appropriate steps to ensure maximum security.**

Smart contract repository for Incentera.

## Testing and development

This project was built using [Foundry](https://github.com/gakonst/foundry).

### Setup

```sh
git clone git@github.com:81k-ltd/incentera-contracts-v1
cd incentera-contracts-v1
forge update
```

### Testing

- To run all tests: `forge test`
- To run tests with a given profile: `export FOUNDRY_PROFILE=ffi`

### Linting & Formatting

Pre-configured `forge fmt`

### CI with Github Actions

Automatically run linting and tests on all pull requests and commits pushed to master.
