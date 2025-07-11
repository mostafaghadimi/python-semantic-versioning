# CHANGELOG


## v2.3.0 (2025-07-12)

### Documentation

- Add documentation for the action
  ([`a94a42b`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/a94a42bfaf6201005eb811b0aa6d0cb1c192af33))

### Features

- Change the version in pyproject file in case of exsistence
  ([`33e8bcf`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/33e8bcfb27ebfb82330fd553944aabee4e619f9c))

### Refactoring

- Improve the entrypoint.sh and action.yml file
  ([`24112e4`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/24112e434584de399d0495ca89c87071b612ca2a))

- Remove default value for commit_author in config.toml file and also add project author
  ([`f99dc0e`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/f99dc0e24c67b1073e4de3f04b6e34b9c678631c))


## v2.2.5 (2025-07-11)

### Bug Fixes

- Use gh_token
  ([`2c71615`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/2c71615ef1ff53c3375a17cfefcb42fd580dc91d))


## v2.2.4 (2025-07-11)

### Bug Fixes

- Add gh_token as required inputs
  ([`0dca5e5`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/0dca5e589be7d462c87600c67c62ba703c95481f))


## v2.2.3 (2025-07-11)

### Bug Fixes

- Remove github_token from inputs
  ([`f51595c`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/f51595c71960ff55dbfb2e7cfade86a7aa7e1899))


## v2.2.2 (2025-07-11)

### Bug Fixes

- Remove unnecessary tag generator
  ([`14f984d`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/14f984d39bed75046d4047080e371c6a3a871714))


## v2.2.1 (2025-07-11)

### Bug Fixes

- Add remote.token table to config
  ([`c473dfc`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/c473dfc953874fab57cfbc69756e8e4c87215086))

- Remove gh_token from inputs
  ([`a44279a`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/a44279a8e5fac5ae7e86ae902ea73c401fa28bb2))


## v2.2.0 (2025-07-11)

### Features

- Add GH_TOKEN and make the github action works properly
  ([`6bdbc27`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/6bdbc27d1c00e4dd180057c5934af92054136ee0))


## v2.1.2 (2025-07-11)

### Bug Fixes

- Resolve the issue with safe.directory
  ([`1815d44`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/1815d4477fa91bc4a5c40fbe30fe563236eed09e))


## v2.1.1 (2025-07-11)

### Bug Fixes

- Comment safe.directory to see what happens
  ([`0f626e2`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/0f626e234f4e2d90bc204e9f154d9aec24972d4b))


## v2.1.0 (2025-07-11)

### Features

- Create initial tag if no tag exists
  ([`515b11e`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/515b11e9b5fed7bfcea7e58710b17a26a616f6d3))


## v2.0.22 (2025-07-11)

### Bug Fixes

- Change the order of execution of verbosity
  ([`f7bde7f`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/f7bde7f43da790ee8ce599ef150878cbe185f5d4))


## v2.0.21 (2025-07-11)

### Bug Fixes

- Add verbosity to semantic-release command
  ([`931ce37`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/931ce37f073f522d7a85764fe984fff6cbdd1eeb))


## v2.0.20 (2025-07-11)

### Bug Fixes

- Export GH_TOKEN and print it
  ([`3aba6f6`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/3aba6f65ad13578767801dbaa050065de19180af))


## v2.0.19 (2025-07-11)

### Bug Fixes

- Remove default value for gh_token
  ([`59cec0a`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/59cec0a1858f2213de2523ff370b82fe7ed5c09d))


## v2.0.18 (2025-07-11)

### Bug Fixes

- Add gh_token as required inputs
  ([`7462ea6`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/7462ea622743d26a3dba63e1a32b4a3553ea1b1e))


## v2.0.17 (2025-07-11)

### Bug Fixes

- Debug the issue with GITHUB_WORKSPACE
  ([`b790cca`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/b790cca82b989a92bcc390ad347aa935ebc399f9))


## v2.0.16 (2025-07-11)

### Bug Fixes

- Remove additional cd command
  ([`921e3e0`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/921e3e094b62fccd75e599c12b241f81113ad554))


## v2.0.15 (2025-07-11)

### Bug Fixes

- Resolve the issue of entrypoint for current working directory
  ([`42b0e68`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/42b0e685ebf369ca59afdb07c23c6e3065bfc8ef))


## v2.0.14 (2025-07-11)

### Bug Fixes

- Resolve the issue of semantic_release_config in action.yml
  ([`7a0abdc`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/7a0abdc7d3797a10c1d1adb4ef7f75b26df5c279))


## v2.0.13 (2025-07-11)

### Bug Fixes

- Resolve the issue with PATH
  ([`c937332`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/c9373320e966512d48a5a08d2e627de5fa849de8))


## v2.0.12 (2025-07-11)

### Bug Fixes

- Resovle the issue with the address of entrypoint
  ([`ac92b8e`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/ac92b8edf92443768676d07f3fc2e165b63c6de1))


## v2.0.11 (2025-07-11)

### Bug Fixes

- Change entrypoint to debug /app
  ([`7a9d9f2`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/7a9d9f2e5c5201f6f732ee20112cc300043d3070))


## v2.0.10 (2025-07-11)

### Bug Fixes

- Resolve the issue of Dockerfile
  ([`ef4fbf5`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/ef4fbf59b350531dd84d54c8853848b960efa0f8))


## v2.0.9 (2025-07-11)

### Bug Fixes

- Debug the code using ls
  ([`3cf827e`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/3cf827e8da5199c28e60df64b7fd4f269872b808))


## v2.0.8 (2025-07-11)

### Bug Fixes

- Remove WORKDIR based on action docs
  ([`69e811b`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/69e811bd394e90d17f58e448b3341cc2b31699f4))


## v2.0.7 (2025-07-11)

### Bug Fixes

- Resolve the issue of Dockerfile
  ([`b72d291`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/b72d29133e865b2c393d0be4cdc3ddb5f04a2ad9))


## v2.0.6 (2025-07-11)

### Bug Fixes

- Add WORKDIR to Dockerfile
  ([`6fb3f2b`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/6fb3f2bd7390d63288d7c096c5713078f7d1bc12))


## v2.0.5 (2025-07-11)

### Bug Fixes

- Add some commands to entrypoint for debugging purpose
  ([`3c93ade`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/3c93ade64a57a8ad801e7244b6d8c0f7c5b12f3c))


## v2.0.4 (2025-07-11)

### Bug Fixes

- Add a line to entrypoint to list all files for debugging purpose
  ([`ca4c967`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/ca4c9672b114f3b1ae6158cbc458125de3403e98))


## v2.0.3 (2025-07-11)

### Bug Fixes

- Move Dockerfile to the root
  ([`08ed344`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/08ed344c976b7cf328ad500c84fd07f1072a9901))


## v2.0.2 (2025-07-11)

### Bug Fixes

- Resolve the issue with pyproject and uv.lock files
  ([`1f738fd`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/1f738fdf6d8cfecca09d85b22e4ed6d98658c9f6))


## v2.0.1 (2025-07-11)

### Bug Fixes

- Resolve the issue with the path of files
  ([`9b58ebb`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/9b58ebb23a29550d2ac560565f6f1ea2e325d566))


## v2.0.0 (2025-07-11)

### Features

- Use Docker instead of composite
  ([`43698ec`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/43698eca3d354bf6ed787aa321d3d7ab67ad8efd))


## v1.0.1 (2025-07-11)

### Bug Fixes

- Add author field to let github publish the action in marketplace
  ([`4c890e5`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/4c890e56a74c6d640d94aed53f965e1b665db771))

- Change the python version
  ([`6a09918`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/6a09918796343a53fcd11df0b809ee7f7dd234e6))

- Replace spaces with tabs
  ([`554d5f0`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/554d5f01bbf33564b3a1479253ca8cbf50890d08))

### Documentation

- Initialize README file that may end in marketplace publishment
  ([`7b706ee`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/7b706ee39e48b9b0be124692dc3ba2cc494395d3))


## v1.0.0 (2025-07-11)

### Chores

- Add ruff to development requirements
  ([`356fb57`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/356fb572f1f270e4fe363c46f2363c310d7e76ed))

### Features

- Add custom commit parser to support DataBurst like commit formats
  ([`193e245`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/193e2454ae71918e2c5e2db607354fde1a4e8675))

- Add initial version of action
  ([`b9eec66`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/b9eec66173b080098b9ffa083a4693e57cb75a61))

- Initialize the project using UV
  ([`0cd0b4b`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/0cd0b4ba355e4b0712d9dac27809f6faea018ba5))

### Refactoring

- Change project name and description in pyproject.toml
  ([`01822d4`](https://github.com/mostafaghadimi/python-semantic-versioning/commit/01822d41acd38c820309ea57d91094478245c2e2))
