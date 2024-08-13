# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## [v0.7.0](https://github.com/explore-bzl/starterkit/compare/004db8ffb55d45c3a67b6b19d27771f3f4da260a..v0.7.0) - 2024-08-13
#### Features
- new image variant containing coreutils - ([004db8f](https://github.com/explore-bzl/starterkit/commit/004db8ffb55d45c3a67b6b19d27771f3f4da260a)) - Artur Stachecki

- - -

## [v0.6.1](https://github.com/explore-bzl/starterkit/compare/6207a8e547a33aa1d1dec841b5451784105815e6..v0.6.1) - 2024-07-12
#### Bug Fixes
- strace images contain /nix/store - ([6207a8e](https://github.com/explore-bzl/starterkit/commit/6207a8e547a33aa1d1dec841b5451784105815e6)) - [@AleksanderGondek](https://github.com/AleksanderGondek)

- - -

## [v0.6.0](https://github.com/explore-bzl/starterkit/compare/bcd66505b628a6300955202dfcb651f58887c5a2..v0.6.0) - 2024-07-01
#### Documentation
- update readme with additional example of similar project - ([bcd6650](https://github.com/explore-bzl/starterkit/commit/bcd66505b628a6300955202dfcb651f58887c5a2)) - [@AleksanderGondek](https://github.com/AleksanderGondek)
#### Features
- new image variant containing strace - ([a578767](https://github.com/explore-bzl/starterkit/commit/a5787676d4916c50bcdcb9f1195fd77dd8492a1d)) - [@AleksanderGondek](https://github.com/AleksanderGondek)
#### Miscellaneous Chores
- **(update)** update the nixpkgs to latest as of 2024-06-30 - ([9674a31](https://github.com/explore-bzl/starterkit/commit/9674a31c431f39651271091242fd3bdb0049bfbd)) - [@AleksanderGondek](https://github.com/AleksanderGondek)

- - -

## [v0.5.1](https://github.com/explore-bzl/starterkit/compare/c52587ef06d334b236b81691846e4d64c8bdc446..v0.5.1) - 2024-06-13
#### Bug Fixes
- **(ci)** do not trigger release process if only BUILD.bazel has changed - ([c52587e](https://github.com/explore-bzl/starterkit/commit/c52587ef06d334b236b81691846e4d64c8bdc446)) - [@AleksanderGondek](https://github.com/AleksanderGondek)

- - -

## [v0.5.0](https://github.com/explore-bzl/starterkit/compare/13ed05a11252593d5ad0f48818af3bc60f1a3ce6..v0.5.0) - 2024-06-13
#### Features
- **(update)** update the nixpkgs to latest as of 2024-06-13 - ([13ed05a](https://github.com/explore-bzl/starterkit/commit/13ed05a11252593d5ad0f48818af3bc60f1a3ce6)) - [@AleksanderGondek](https://github.com/AleksanderGondek)

- - -

## [v0.4.0](https://github.com/explore-bzl/starterkit/compare/e57bdb770bdf87714a04841ac90ff3ff6793b07f..v0.4.0) - 2024-05-27
#### Features
- create Bazel platform definitions - ([e57bdb7](https://github.com/explore-bzl/starterkit/commit/e57bdb770bdf87714a04841ac90ff3ff6793b07f)) - [@AleksanderGondek](https://github.com/AleksanderGondek)

- - -

## [v0.3.0](https://github.com/explore-bzl/starterkit/compare/3895c0e8690314663fab23d69cc687c569abe2c7..v0.3.0) - 2024-05-15
#### Documentation
- rewrite readme to be more clear - ([3895c0e](https://github.com/explore-bzl/starterkit/commit/3895c0e8690314663fab23d69cc687c569abe2c7)) - [@AleksanderGondek](https://github.com/AleksanderGondek)
#### Features
- **(test)** adds justbuild test images - ([c46226e](https://github.com/explore-bzl/starterkit/commit/c46226edb57e975c9c865af21cda83a09042331e)) - Artur Stachecki
#### Miscellaneous Chores
- **(docs)** add description to the generated table - ([f3bbe8c](https://github.com/explore-bzl/starterkit/commit/f3bbe8c9c9752fba8929b31e6f7495a6efd139d8)) - Artur Stachecki
- specify MIT license for the project - ([f448fb2](https://github.com/explore-bzl/starterkit/commit/f448fb251d4eb69b17b107437d6edada0327fad0)) - [@AleksanderGondek](https://github.com/AleksanderGondek)

- - -

## [v0.2.0](https://github.com/explore-bzl/starterkit/compare/7708120866140595a5d4172c4b4e084ab520389b..v0.2.0) - 2024-05-03
#### Bug Fixes
- **(cicd)** github actions lack of permissions and wrong triggers - ([815efc8](https://github.com/explore-bzl/starterkit/commit/815efc8cfcf4f760ef28e3e49a6d51f774522b9d)) - [@AleksanderGondek](https://github.com/AleksanderGondek)
#### Features
- **(ci)** unify checks run by cog and ci - ([7708120](https://github.com/explore-bzl/starterkit/commit/7708120866140595a5d4172c4b4e084ab520389b)) - [@AleksanderGondek](https://github.com/AleksanderGondek)
- **(cicd)** introduce automated releasing process - ([89f5ae9](https://github.com/explore-bzl/starterkit/commit/89f5ae9c55f0f167ccad7188f7eadd3efd964f64)) - [@AleksanderGondek](https://github.com/AleksanderGondek)

- - -

## v0.1.0 - 2024-05-02
#### Bug Fixes
- missing ash image variant - (e9d40f5) - Artur Stachecki
- mechanism to push images - (a8ec3ff) - AleksanderGondek
- glibc binary tests - (d558427) - Artur Stachecki
- missing contents dir links - (ed1c93f) - Artur Stachecki
#### Documentation
- update the README to fully describe the project - (a3d63e5) - AleksanderGondek
#### Features
- introduce simple script for running the test images - (b8a377f) - AleksanderGondek
- add bubblewrap outputs - (f110d9e) - Artur Stachecki
- adds libstdcxx variants - (433aa99) - Artur Stachecki
- remove memory-mapped locale-archive - (19189b9) - Artur Stachecki
- add tests via container images - (413789d) - AleksanderGondek
- publish container images script generation added - (87db1dd) - AleksanderGondek
#### Miscellaneous Chores
- introduce cog release process - (922b8b0) - AleksanderGondek
- simplify variant generation and filtering - (be42469) - Artur Stachecki
- introduce README.md generation - (a2d53e0) - AleksanderGondek
- remove repetition from devShell.nix - (fa68c07) - AleksanderGondek
- update nixpkgs to latest as of 2024-04-27 - (5d77a50) - AleksanderGondek
- git ignore multiple nix-build outputs - (0dafb3f) - AleksanderGondek
- add readme image matrix script and mdsh tool - (39f42e9) - Artur Stachecki
- introduce CD - (98ebb00) - AleksanderGondek
#### Refactoring
- attrset structure - (1c0b2fa) - Artur Stachecki
- extract common functions to nix/lib - (7aae272) - Artur Stachecki
- compile test binaries using gccMultiStdenv - (f2e8918) - Artur Stachecki
- various fixes found by linters - (7a384ca) - AleksanderGondek
- package structure and use callPackage - (cb48fa6) - Artur Stachecki
- improve the structure of nix files - (356d5fb) - AleksanderGondek
- container image building - (43ae177) - Artur Stachecki
- reduce expressions - (d4af172) - Artur Stachecki

- - -

## v0.0.0 - 2024-05-02
#### Features
- nixify the container creation - (46271ca) - AleksanderGondek

- - -

Changelog generated by [cocogitto](https://github.com/cocogitto/cocogitto).