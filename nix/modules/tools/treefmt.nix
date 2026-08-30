{
  lib,
  pkgs,
  ...
}: {
  enableDefaultExcludes = false;
  programs = {
    actionlint.enable = true;
    alejandra = {
      enable = true;
      priority = 10;
    };
    beautysh.enable = true;
    deadnix.enable = true;
    djlint = {
      enable = true;
      indent = 2;
      lint = true;
      priority = 10;
    };
    dockerfmt.enable = true;
    dockfmt.enable = true;
    dos2unix.enable = true;
    flake-edit.enable = true;
    genemichaels.enable = true;
    gofmt.enable = true;
    gofumpt.enable = true;
    goimports.enable = true;
    golangci-lint.enable = true;
    just.enable = true;
    keep-sorted.enable = true;
    nbstripout.enable = true;
    nixf-diagnose.enable = true;
    nixfmt = {
      enable = true;
      priority = 1;
    };
    nixpkgs-fmt.enable = false;
    oxfmt = {
      enable = true;
      priority = 80;
    };
    pedantix = {
      enable = true;
      settings.attrs = {
        blank-lines = 0;
        flatten = true;
        merge = true;
      };
    };
    prettier = {
      enable = true;
      priority = 100;
    };
    ruff-check = {
      enable = true;
      priority = 8;
    };
    ruff-format = {
      enable = true;
      priority = 9;
    };
    rustfmt.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
    sort-markdown-tables = {
      enable = true;
      priority = 3;
    };
    sqlfluff.enable = true;
    sqlfluff-lint.enable = true;
    statix.enable = true;
    taplo = {
      enable = true;
      priority = 15;
      settings.formatting = {
        array_auto_expand = true;
        array_trailing_comma = false;
      };
    };
    toml-sort.enable = true;
    typos = {
      enable = true;
      excludes = [
        # keep-sorted start
        "**/cspell.json"
        ".config/cspell.json"
        "CHANGELOG.md"
        # keep-sorted end
      ];
    };
    typstyle = {
      enable = true;
      priority = 1;
    };
    xmllint.enable = true;
    yamllint = {
      enable = true;
      priority = 9;
      settings = {
        extends = "default";
        rules = {
          comments = "disable";
          line-length = "disable";
          truthy = "disable";
        };
      };
    };
    zizmor.enable = true;
  };
  projectRootFile = "flake.nix";
  settings = {
    formatter = {
      cspell-sort = {
        command = "${lib.getExe pkgs.yq-go}";
        includes = [
          # keep-sorted start
          "**/.CSpell*"
          "**/.cspell*"
          "**/cSpell*"
          "**/cspell*"
          ".CSpell*"
          ".cspell*"
          "cspell*"
          # keep-sorted end
        ];
        no-positional-arg-support = true;
        options = [
          "-i"
          ".words|= sort_by(downcase)|.ignorePaths|=sort_by(downcase)"
        ];
        priority = 9;
      };
    generate-package-table = {
      command = "uv";
      includes = ["Packages.md", "**/packages/**"];
      options = ["run", "gen-packages-table"];
      priority = 1;
    };
      djlint.options = ["--single-attribute-per-line"];
      prettypst-default = {
        command = "${lib.getExe pkgs.prettypst}";
        includes = ["*.typ"];
        no-positional-arg-support = true;
        options = [
          "-s"
          "default"
        ];
        priority = 2;
      };
      prettypst-otbs = {
        command = "${lib.getExe pkgs.prettypst}";
        includes = ["*.typ"];
        no-positional-arg-support = true;
        options = [
          "-s"
          "otbs"
        ];
        priority = 3;
      };
      tombi-format = {
        command = "${lib.getExe pkgs.tombi}";
        includes = ["*.toml"];
        options = [
          "format"
          "--offline"
        ];
        priority = 11;
      };
      toml-sort.options = [
        "--sort-inline-tables"
        "--sort-table-keys"
      ];
      yamlfix = {
        command = "${lib.getExe pkgs.yamlfix}";
        includes = [
          # keep-sorted start
          "*.yaml"
          "*.yml"
          # keep-sorted end
        ];
        priority = 8;
      };
      yq-packages-sort = {
        command = "${lib.getExe pkgs.yq-go}";
        no-positional-arg-support = true;
        includes = [
          # keep-sorted start
          "**/.chezmoidata/distros.yaml",
          "**/.chezmoidata/packages/**/*.json",
          "**/.chezmoidata/packages/**/*.yaml",
          "**/.chezmoidata/packages/**/*.yml",
          "**/.chezmoidata/packages/*.json",
          "**/.chezmoidata/packages/*.yaml",
          "**/.chezmoidata/packages/*.yml"
          # keep-sorted end
        ];
        options = [
          "eval"
          "-i"
          "'(.. | select(tag == \"!!seq\")) |= (sort_by(. | downcase))'"
        ];
        priority = 0;
      };
      yq-key-sort = {
        command = "${lib.getExe pkgs.yq-go}";
        includes = [
          # keep-sorted start
          "*.json"
          "*.yaml"
          "*.yml"
          # keep-sorted end
        ];
        no-positional-arg-support = true;
        options = [
          "-P"
          "-i"
          "sort_keys(..)"
        ];
        priority = 0;
      };
    };
    global = {
      allow-missing-formatter = true;
      excludes = [
        # keep-sorted start
        "**/apm_modules/**"
        "**/node_modules/**"
        "**/skills/**"
        ".gitattributes"
        # keep-sorted end
      ];
    };
  };
}
