{
  flake,
  pkgs,
  ...
}:
pkgs.mkShell {
  inherit (flake.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check) shellHook;
  packages = with pkgs; [
    # keep-sorted start
    bun
    cocogitto
    copier
    git
    git-credential-oauth
    glab
    lazygit
    nil
    nixd
    repgrep
    ripgrep
    uv
    # keep-sorted end
  ];
}
