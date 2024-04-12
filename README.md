# StarterKit
Welcome to StarterKit! Imagine this as your trusty backpack, filled with just the essentials you need for building software across different lands - I mean, Linux distributions. Inspired by the Yocto Project's Uninative concept (a cool mix of "universal" and "native"), we're all about making sure you get a smooth and consistent build experience.

Inside this kit, you'll find everything tuned for running both the old-school 32bit and the more modern 64bit Linux ELF binaries. What's in the box? A dynamic linker/loader, the latest glibc, and an "Ash" shell from busybox that's as reliable as your favorite multi-tool.

### Starters include
## empty
This Starter is as empty as it gets, a blank canvas awaiting your unique touch.

## ash
Solo trainer mode.

## i386 / ash-i386
Perfect for those nostalgic or simpler adventures.

## x86_64 / ash-x86_64
The choice of champions and the most sought-after among trainers.

## x86_64-i386 / ash-x86_64-i386
For those who've embarked on the quest to catch 'em all.

## Crafting Your Starter
```
docker build . -t starter
```

## How to Use Your Starters
### For Local Training
```
docker run -it --rm starter:latest
```

### As a Remote Gym Leader
1. Define your gym's platform in Bazel as follows:
```
# exec_platforms/BUILD.bazel
platform(
    name = "starter",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    exec_properties = {
        "container-image": "docker://your.build.league/starter@sha256:acb0d018dc58736e9cb9ac23d8dd095cd38dea0d4f790dca4a0b04d41c7c8f3e",
            "dockerRunAsRoot": "true"
    },
)
```

2. Prepare your .bazelrc for the upcoming battles:
```
# .bazelrc
build:remote --bes_results_url=https://your.build.center/invocation/
build:remote --bes_backend=grpcs://grpc.buildleague.com
build:remote --remote_cache=grpcs://buildstorage.best
build:remote --remote_timeout=3600
build:remote --remote_executor=grpcs://trusted.buildcompanion.com
build:remote --jobs=64
build:remote --experimental_guard_against_concurrent_changes

build:remote --strategy=remote
build:remote --genrule_strategy=remote
build:remote --spawn_strategy=remote

build:remote --extra_execution_platforms=//exec_platforms:starter
```

3. Challenge the league with `remote` config:
```
bazel build //battle:showdown --config=remote
```

## How to publish the images
```
$ $(nix-build --no-out-link default.nix -A containerImages.starterKit-i686.push) <docker-registry> <username> <password>
$ $(nix-build --no-out-link default.nix -A containerImages.starterKit-x86_64.push) <docker-registry> <username> <password>
$ $(nix-build --no-out-link default.nix -A containerImages.starterKit-x86_64-i686.push) <docker-registry> <username> <password>
```
