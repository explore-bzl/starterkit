{lib}: let
  inherit
    (lib)
    cartesianProductOfSets
    concatStringsSep
    filter
    nameValuePair
    listToAttrs
    ;
in {
  join = sep: parts: concatStringsSep sep (filter (s: s != "") parts);

  genVariants = {
    filter ? null,
    attrs,
  }:
    if builtins.isNull filter
    then (cartesianProductOfSets attrs)
    else filter (cartesianProductOfSets attrs);

  buildPackages = {
    metaFun,
    buildFun,
    variants,
  }:
    listToAttrs (map (variant: let
      meta = metaFun variant;
    in
      nameValuePair meta.name (buildFun (meta // variant)))
    variants);
}
