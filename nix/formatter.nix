{
  flake,
  inputs,
  pkgs,
  ...
}: let
  treefmtEval = inputs.treefmt.lib.evalModule pkgs {
    imports = [
      flake.modules.tools.treefmt
      inputs.pedantix.treefmtModules.default
      inputs.smt.treefmtModules.default
    ];
  };
in
  treefmtEval.config.build.wrapper.overrideAttrs (old: {
    passthru =
      (old.passthru or {})
      // {
        check = treefmtEval.config.build.check flake;
      };
  })
