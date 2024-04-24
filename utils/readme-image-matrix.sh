# !/usr/bin/env bash
# This script dynamically generates a Markdown table listing  
# container images and their respective pull commands.

set -euo pipefail

[ "$#" -ne 1 ] && echo "Usage: $0 <registry-url>" && exit 1

nix-instantiate --argstr registry_url "$1" --eval -E '
{registry_url}:
with builtins;

let
  findGitRoot = dir:
    if dir == "/" then
      throw "No .git directory found in any parent directory"
    else if pathExists (dir + "/.git") then
      dir
    else
      findGitRoot (dirOf dir);

  currentDir = getEnv "PWD";
  repoRoot = findGitRoot currentDir;
  containerImages = (import repoRoot {}).containerImages;
in
  "| Image | Pull |\n| ---   | ---  |\n" +
  concatStringsSep "\n" (map (name: let
      tag = containerImages.${name}.image.out.imageTag;
      pullCommand = "${registry_url}/${name}:${tag}";
    in
      "| ${name} | \`${pullCommand}\` |")
    (filter (name: name != "override" && name != "overrideDerivation")
      (attrNames containerImages)))
' | xargs echo -e

