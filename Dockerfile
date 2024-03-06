FROM nixery.dev/shell/glibc.bin/nix as base
COPY default.nix /

ENV NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs/archive/bfa8b30043892dc2b660d403faa159bab7b65898.tar.gz 
RUN : \
&& nix-build -E --expr 'with (import <nixpkgs> {}); callPackage ./. {}' \
   -A busybox_static --out-link busybox --option build-users-group '' \
&& nix-build -E --expr 'with (import <nixpkgs> {}); callPackage ./. {}' \
   -A ash --out-link ash --option build-users-group ''

FROM scratch AS build
COPY --from=base /busybox/bin /bin
COPY --from=base /bin/ldconfig /ldconfig
COPY build.sh /
RUN ./build.sh mixed

FROM scratch
COPY --from=base /ash/bin/busybox /bin/sh
COPY --from=build /lib /lib
COPY --from=build /lib64 /lib64
COPY --from=build /etc/ld.so.cache /etc/ld.so.cache
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /usr/local /usr/local
COPY --from=build /usr/lib /usr/lib
