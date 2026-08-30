{
  inputs,
  lib ? pkgs.lib,
  pkgs,
  ...
}:
inputs.git-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
  hooks = {
    betterleaks = {
      args = [
        "--redact"
        "--verbose"
        "git"
        "--staged"
        "--pre-commit"
      ];
      enable = true;
      entry = lib.getExe pkgs.betterleaks;
      name = "betterleaks";
      pass_filenames = false;
      stages = ["pre-commit"];
    };
    check-merge-conflicts.enable = true;
    cocogitto = {
      args = [
        "verify"
        "--file"
      ];
      enable = true;
      entry = lib.getExe pkgs.cocogitto;
      name = "Cocogitto commits check";
      stages = ["commit-msg"];
    };
    cspell = {
      args = [
        "--config"
        ".config/cspell.json"
        "--no-must-find-files"
        "--no-progress"
        "--no-summary"
      ];
      enable = true;
      stages = [
        "commit-msg"
        "pre-commit"
      ];
    };
    forbidden-files = {
      enable = true;
      entry = "found Copier update rejection files; review and remove them before merging.";
      files = "\\.rej$";
      language = "fail";
      name = "forbidden files";
    };
    ls-lint = {
      enable = true;
      entry = lib.getExe pkgs.ls-lint;
      name = "ls-lint";
      stages = ["pre-commit"];
    };
    ripsecrets.enable = true;
    typos = {
      enable = true;
      settings.configPath = "./.typos.toml";
      stages = [
        "commit-msg"
        "pre-commit"
      ];
    };
  };
  package = pkgs.prek;
  src = inputs.self;
}
