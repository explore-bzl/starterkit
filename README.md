# "glibc"-only containers

Starterkit is a distro-agnostic, vertical slice of Linux FHS, trimmed down to provide only a functional "glibc". Effectively, it consists only of `/lib/{arch}-linux-gnu`.

## Why? What problem does this project solve?
It is a pragmatic way of validating / ensuring that a certain executed binary is either: (1) delivered with its own dependencies (self-contained) or (2) relies solely on glibc and references it in a portable manner.

In other words, Starterkit is an execution environment crafted specifically to only allow glibc as a pre-existing dependency that can be relied upon. Any other assumptions will break the execution, even if it refers to files / directories mentioned in Linux FHS or some specific Linux distro.

## Comparison against similar projects
1. [Google distroless containers](https://github.com/GoogleContainerTools/distroless) - created images are connected to Debian distribution and contain the whole base filesystem hierarchy that the Starterkit specifically wants to prevent from being used. If you do not care about that aspect, this is the project you should use.
2. [Alpine containers](https://github.com/alpinelinux/docker-alpine) - created images are using muslc - even with `glibc` compatibility lib, there is a risk of binaries written for `glibc` to misbehave. If you do not care about that risk, and you do not mind Linux FHS you should try it out.

## Base operating system

None. Starterkit is not based on any Linux distro and it obtains its `glibc` from [Yocto Uninative project](https://docs.yoctoproject.org/gatesgarth/ref-manual/ref-classes.html#uninative-bbclass). 

Currently used version of uninative: **4.4 (glibc 2.38)**.

## How to...

### Use the container images?

The images are built using [nix](https://nixos.org/explore/) but they can be used by any [OCI Certified](https://opencontainers.org/community/certified/) runtime.

### Know what images are available?

`> ./utils/readme-image-matrix.sh harbor.apps.morrigna.rules-nix.build/explore-bzl`

<!-- BEGIN mdsh -->
| Image | Pull |
| ---   | ---  |
| ash | `harbor.apps.morrigna.rules-nix.build/explore-bzl/ash:9m7shakbx4g5afqggrjml6d9ysw64kgl` |
| ash-i686 | `harbor.apps.morrigna.rules-nix.build/explore-bzl/ash-i686:8yg4l9249799q4ydvni5rp9mqdxjkimq` |
| ash-i686-cc | `harbor.apps.morrigna.rules-nix.build/explore-bzl/ash-i686-cc:13dhvdm6z1hm1s7mfydhijvf7h64rs52` |
| ash-i686-cc-x86_64 | `harbor.apps.morrigna.rules-nix.build/explore-bzl/ash-i686-cc-x86_64:aryxnryzd2jvg6pah2r7vy0n08dbkdr4` |
| ash-i686-cc-x86_64-cc | `harbor.apps.morrigna.rules-nix.build/explore-bzl/ash-i686-cc-x86_64-cc:xhbp98gdf9zkd60n435p5kj7nmxgixkx` |
| ash-i686-x86_64 | `harbor.apps.morrigna.rules-nix.build/explore-bzl/ash-i686-x86_64:v4cc6x5wi80185k982ilaslq9a08vsf5` |
| ash-i686-x86_64-cc | `harbor.apps.morrigna.rules-nix.build/explore-bzl/ash-i686-x86_64-cc:p9z58x2kw7rk9vsmjd7dhr2lg24la50m` |
| ash-x86_64 | `harbor.apps.morrigna.rules-nix.build/explore-bzl/ash-x86_64:rs8fyxa4f18siygkxssiqif5nk14imsq` |
| ash-x86_64-cc | `harbor.apps.morrigna.rules-nix.build/explore-bzl/ash-x86_64-cc:zc2k8n6yprz8iciywgbb1npjbfdmd3nh` |
| i686 | `harbor.apps.morrigna.rules-nix.build/explore-bzl/i686:ck33qcynskzvrb2310w73656b9154ny8` |
| i686-cc | `harbor.apps.morrigna.rules-nix.build/explore-bzl/i686-cc:vlw6915jv2s2dqjj43a9y94zj7531qsx` |
| i686-cc-x86_64 | `harbor.apps.morrigna.rules-nix.build/explore-bzl/i686-cc-x86_64:zyna188bilq5718j54saliy2zb3l47nm` |
| i686-cc-x86_64-cc | `harbor.apps.morrigna.rules-nix.build/explore-bzl/i686-cc-x86_64-cc:bzy7fxlvnpkbmigj0z38skdld37cpchv` |
| i686-x86_64 | `harbor.apps.morrigna.rules-nix.build/explore-bzl/i686-x86_64:w6l0kam2xxxr8a3zzz8vy2nfcyds4lbb` |
| i686-x86_64-cc | `harbor.apps.morrigna.rules-nix.build/explore-bzl/i686-x86_64-cc:jhsnzvsndhcfv9khvvfpqamplcc4d4c8` |
| x86_64 | `harbor.apps.morrigna.rules-nix.build/explore-bzl/x86_64:ynq9g99wqj5xf9cvag6smigbwh89hpap` |
| x86_64-cc | `harbor.apps.morrigna.rules-nix.build/explore-bzl/x86_64-cc:68sscdrdk171kqjdmpqwgg4ncy4y4j7d` |
<!-- END mdsh -->

### Use Starterkit as Bazel RBE platform?
1. Define the platform as follows:
```
# exec_platforms/BUILD.bazel
platform(
    name = "starterkit",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    exec_properties = {
        "container-image": "docker://harbor.apps.morrigna.rules-nix.build/explore-bzl/starterkit-ash-x86_64@sha256:38290c15c950643e52b10e326cc1889fd06f5ebf4f0bb4453ad4351e8e8daf0f",
    },
)
```

2. Prepare your .bazelrc for the RBE
```
# .bazelrc
build:remote --remote_executor=grpcs://rbe.build.com
build:remote --experimental_guard_against_concurrent_changes

build:remote --strategy=remote
build:remote --genrule_strategy=remote
build:remote --spawn_strategy=remote

build:remote --extra_execution_platforms=//exec_platforms:starterkit
```

3. Run the builds with `remote` config:
```
bazel build //battle:showdown --config=remote
```

### Build the images from scratch?

```
$ nix-build default.nix -A containerImages.starterKit-x86_64.image
```

### Publish the images?

```
$ $(nix-build --no-out-link default.nix -A containerImages.starterKit-i686.push) <docker-registry> <username> <password>
```

## Project origins
One of the main appeals of Bazel and its Remote Build Execution, is that it can reduce the build times of large, heterogeneous build systems from hours to seconds. To fulfill that premise. Bazel actions have to be reproducible and hermetic [1]. The latter means that all of the entities involved in the build (source code, compilers but also compiler deps etc.) are isolated from the host system and the state of said host does affect the build. For all practical purposes, it means describing all dependencies in such a way that Bazel may place  them and use them from within its `execroot` [2] (which in turn, vastly improves composability). 

Said approach is not easy to achieve in practice - many tools, compilers, Bazel rules and even Bazel itself (sic!) [3] assume things to be present on the host machine that executes Bazel action and reach out of the `execroot` without second thought. While it is acceptable compromise, where given Bazel WORKSPACE builds only for a very limited amount of configurations (of target Architecture, OS, etc.), it very quickly becomes troublesome in setups that need to cross-compile for a myriad of target platforms, especially when intermediate code-generation steps are involved. 

Simple example is a CPP project that has to be compiled for many architectures (aarch64, amd64, mipsel, ppce64 … and more)  - the choice is either to have dedicated worker machines with matching architecture or use cross-compilers. While using cross-compilers, one can use container images with globally installed packages (pinned-down per target architecture) or describe the toolchains so that they are all relocated under `execroot`. In all but last approaches, Bazel does not really govern compilation dependencies and they are managed external to the WORKSPACE, which invites a lot of places for the hermeticity to be broken.  

This project is the result of suffering through making aforementioned toolchains, dependencies and tools to be relocatable under `execroot` and having their dependencies fully described so that the Bazel RBE may easily compose an action environment for all iof its needs and use minimal container images. 

As it is not always practical or possible, to trace all dependencies of a given tool/compiler/Bazel rule/etc. upfront, Starterkit makes it dead simple to validate if a build is truly not depending on anything else but the bare `glibc` - by the means of stripping everything else. This approach both provides a minimal execution environment for Bazel RBE and does ensure, that nothing besides glibc is used. 

The cut-off point has been chosen for the `glibc` level, as in the author's experience, there is a significant amount of binaries that will need a non-trivial amount of work to be used without it. Therefore it is a compromise between attempt to make Bazel builds truly hermetic and the limitations of prevalent applications. 

---

[1] Hermeticity described in Bazel docs: https://bazel.build/basics/hermeticity 

[2] What is Bazel execroot: https://bazel.buil/remote/output-directories 

[3] Example of Bazel own non-hermetic assumptions: https://github.com/bazelbuild/bazel/blob/45dc2fc960216d1ee772f1a9c8d0c4d5524b76f4/tools/test/test-setup.sh 
