# git-credential-libsecret cross-distro install

**Date:** 2026-11-03
**Question:** How to install git-credential-libsecret across any distro?

## Summary

`git-credential-libsecret` is a **contrib** credential helper in the upstream Git tree (`contrib/credential/libsecret/`). It is **not** built with core Git by default; distros either ship a binary subpackage, bake the binary into `git`, or ship only the C sources for local compile. Upstream documents it as the Linux platform helper for XDG Secret Service (GNOME Keyring, KWallet, etc.).

There is **no single native package name on every distro**. The most reliable distro-agnostic install paths are:

1. **Prefer the distro package** when it exists (`git-credential-libsecret` on Fedora/RHEL-family/Alpine/openSUSE; binary inside Arch's `git`).
2. **On Debian/Ubuntu**, there is no prebuilt helper binary in the `git` package—only contrib sources under `/usr/share/doc/git/contrib/credential/libsecret/`; build with `make` after installing `libsecret`/`glib` devel packages.
3. **Truly cross-distro:** build from upstream's Makefile in `contrib/credential/libsecret`, **or** install Homebrew's `git-credential-libsecret` formula (bottles for Linux x86_64/ARM64 and macOS).

`mise`/`asdf`, Flatpak/Snap, and language package managers (cargo/npm/PyPI) do not appear to ship this helper as a first-party artifact.

## What it is

- Lives at [`contrib/credential/libsecret/`](https://github.com/git/git/tree/master/contrib/credential/libsecret) in [git/git](https://github.com/git/git): `git-credential-libsecret.c`, `Makefile`, `meson.build`.
- Status is **contrib**, not core: upstream `contrib/README` states contrib tools are part of the official tree but separately owned/built and may need separate install. ([contrib/README](https://raw.githubusercontent.com/git/git/master/contrib/README))
- Added in 2016 as a libsecret-based replacement for the deprecated gnome-keyring helper, targeting any XDG Secret Service implementation. ([commit 87d1353](https://github.com/git/git/commit/87d1353a6a133aafd2ef29ba6c740a8d3d71dadb))
- The C helper calls `secret_service_get_sync` / store / clear APIs and fails with "could not connect to Secret Service" if no provider is available. ([source](https://raw.githubusercontent.com/git/git/master/contrib/credential/libsecret/git-credential-libsecret.c))

Core Git only documents built-in helpers `cache` and `store`; libsecret is listed among popular platform helpers, not as "Included in Git." ([gitcredentials](https://git-scm.com/docs/gitcredentials), [credential-helpers](https://git-scm.com/doc/credential-helpers))

## Upstream / official docs

| Topic                 | Upstream guidance                                                                                                                                                                                                                                                                      |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Role                  | "stores in Linux secret service such as GNOME Keyring or KDE Wallet. Packaged in many Linux distributions." ([credential-helpers](https://git-scm.com/doc/credential-helpers))                                                                                                         |
| macOS / Windows peers | `git-credential-osxkeychain` (macOS installs); `git-credential-wincred` / Git Credential Manager (Windows). Same pages.                                                                                                                                                                |
| Enabling a helper     | Put the name in `credential.helper`. Non-absolute names get `git credential-` prepended, so `libsecret` runs `git credential-libsecret` if that binary is on `$PATH` / `$GIT_EXEC_PATH`. Absolute paths are used verbatim. ([gitcredentials](https://git-scm.com/docs/gitcredentials)) |
| Discover helpers      | `git help -a \| grep credential-` then `git help credential-<name>`.                                                                                                                                                                                                                   |

Example from upstream docs:

```bash
git config --global credential.helper libsecret
# or absolute:
git config --global credential.helper /path/to/git-credential-libsecret
```

## Per-distro packages

| Distro family                   | Package / location                                                                                                                                                                           | Prebuilt binary?                                                                                                                                                                                                                                                                                                                                                                                                | Notes                                                                                                                                                                                                                                                                                                                                |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Debian / Ubuntu**             | `git` ships **sources only**: `/usr/share/doc/git/contrib/credential/libsecret/{Makefile,git-credential-libsecret.c}`                                                                        | **No** binary named `git-credential-libsecret` in package contents (sid search hits the `.c` file only). ([Debian sid contents](https://packages.debian.org/search?mode=filename&searchon=contents&keywords=git-credential-libsecret&suite=sid), [Debian sid git filelist](https://packages.debian.org/sid/armel/git/filelist), [Ubuntu noble git filelist](http://packages.ubuntu.com/noble/all/git/filelist)) | Build locally; need `libsecret-1-dev`, `libglib2.0-dev`, `pkg-config`, `gcc`/`make` (pkg names from Debian packaging of those libraries). Runtime: `libsecret-1-0` + a Secret Service provider.                                                                                                                                      |
| **Fedora**                      | Subpackage **`git-credential-libsecret`** of `git`                                                                                                                                           | Yes → `/usr/libexec/git-core/git-credential-libsecret`                                                                                                                                                                                                                                                                                                                                                          | ([Fedora package page](https://packages.fedoraproject.org/pkgs/git/git-credential-libsecret/), [Rawhide files](https://packages.fedoraproject.org/pkgs/git/git-credential-libsecret/fedora-rawhide.html)) Depends on `git-core`, `glib2`, `libsecret`.                                                                               |
| **RHEL / CentOS Stream / Alma** | Same name **`git-credential-libsecret`** in AppStream (verified via RPM indexes for el8/el9/el10 and Alma).                                                                                  | Yes                                                                                                                                                                                                                                                                                                                                                                                                             | Same naming as Fedora; install with `dnf`/`yum`.                                                                                                                                                                                                                                                                                     |
| **Arch / Manjaro**              | Built into **`git`** (Extra); no separate package name                                                                                                                                       | Yes → `/usr/lib/git-core/git-credential-libsecret`                                                                                                                                                                                                                                                                                                                                                              | Optional deps: `libsecret`, `org.freedesktop.secrets` (gnome-keyring, kwallet, keepassxc, …). ([Arch git package](https://archlinux.org/packages/extra/x86_64/git/), [files](https://archlinux.org/packages/extra/x86_64/git/files/), [PKGBUILD](https://gitlab.archlinux.org/archlinux/packaging/packages/git/-/raw/main/PKGBUILD)) |
| **openSUSE**                    | **`git-credential-libsecret`** RPM in OSS (Tumbleweed / Leap)                                                                                                                                | Yes (e.g. Tumbleweed `git-credential-libsecret-2.56.0-*.rpm` under [download.opensuse.org Tumbleweed oss](https://download.opensuse.org/tumbleweed/repo/oss/x86_64/))                                                                                                                                                                                                                                           | Install via `zypper`. Typical install path reported in package indexes: under `libexec` for git (confirm with `rpm -ql` after install).                                                                                                                                                                                              |
| **Alpine**                      | **`git-credential-libsecret`** (origin `git`, main)                                                                                                                                          | Yes                                                                                                                                                                                                                                                                                                                                                                                                             | Depends on `git`, musl, glib, libsecret. ([Alpine pkgs](https://pkgs.alpinelinux.org/package/edge/main/x86_64/git-credential-libsecret))                                                                                                                                                                                             |
| **Nix / NixOS**                 | Not a separate attr by default; enable with `pkgs.git.override { withLibsecret = true; }` which builds `contrib/credential/libsecret` and links into `$out/libexec/git-core` and `$out/bin`. | Yes when overridden                                                                                                                                                                                                                                                                                                                                                                                             | ([nixpkgs git/default.nix](https://github.com/NixOS/nixpkgs/blob/release-25.11/pkgs/applications/version-management/git/default.nix); community wiki example: [NixOS Wiki Git](https://nixos.wiki/wiki/Git))                                                                                                                         |
| **Guix**                        | No clear first-party package page confirming a dedicated `git-credential-libsecret` output was found during this pass.                                                                       | Uncertain                                                                                                                                                                                                                                                                                                                                                                                                       | Treat as **build-from-contrib** or verify on [guix.gnu.org/packages](https://guix.gnu.org/packages/) before relying on a package name.                                                                                                                                                                                               |

### macOS / Windows (relevant peers)

- **macOS:** Upstream recommends `git-credential-osxkeychain` (included with macOS Git). Homebrew also bottles `git-credential-libsecret`, but that still needs a Secret Service–compatible backend (not the native Keychain API). Prefer osxkeychain on macOS unless you intentionally use libsecret. ([credential-helpers](https://git-scm.com/doc/credential-helpers), [Homebrew formula](https://formulae.brew.sh/formula/git-credential-libsecret))
- **Windows:** `git-credential-wincred` and/or Git Credential Manager (included with Git for Windows). ([credential-helpers](https://git-scm.com/doc/credential-helpers))

## Distro-agnostic options (build from source)

### 1. Upstream contrib Makefile (most portable "any Linux")

From a Git source checkout (or the contrib copy shipped by Debian/Ubuntu):

```bash
# build deps (names vary): pkg-config, gcc, make, libsecret + glib development packages
cd contrib/credential/libsecret   # or /usr/share/doc/git/contrib/credential/libsecret
make
sudo make install   # installs to $(prefix)/libexec/git-core (default prefix=/usr/local)
```

Makefile facts ([upstream Makefile](https://raw.githubusercontent.com/git/git/master/contrib/credential/libsecret/Makefile)):

- Links with `pkg-config --cflags/--libs libsecret-1 glib-2.0`
- Default install: `$(prefix)/libexec/git-core` with `prefix ?= /usr/local`
- Targets: `all`, `install`, `clean`

### 2. Homebrew / Linuxbrew

```bash
brew install git-credential-libsecret
```

- Formula builds from Git's `contrib/credential/libsecret` and installs the binary to Homebrew's `bin`.
- Bottles for **Linux ARM64 / x86_64** and macOS. Depends on `glib`, `libsecret`, `pkgconf` (build). ([formulae.brew.sh](https://formulae.brew.sh/formula/git-credential-libsecret), [Formula source](https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/git-credential-libsecret.rb))

This is the strongest **single-command, multi-distro** option if Homebrew is already available.

### 3. Version managers (`mise`, `asdf`)

No first-party `git-credential-libsecret` plugin/package was found in this research pass. Installing Git via mise/asdf does **not** imply the contrib helper is built. Prefer distro packages, Homebrew, or contrib `make`.

### 4. Flatpak / Snap / AppImage

No official Flatpak/Snap/AppImage dedicated to this helper was found on primary catalogs during this pass. Unsuitable as a cross-distro strategy for a small PATH helper.

### 5. cargo / npm / PyPI

No upstream crates.io / npm / PyPI package for `git-credential-libsecret` (npm and PyPI returned 404 for that name; helper is a C program in Git contrib). Do not expect language-package installs.

## Runtime requirements

1. **libsecret** (client library) — linked at build/runtime (`libsecret-1`).
2. **Secret Service** D-Bus provider implementing `org.freedesktop.secrets` — e.g. GNOME Keyring, KWallet (with Secret Service support), KeePassXC, etc. Arch explicitly lists `org.freedesktop.secrets` as an optional dependency of `git` for the keyring helper. ([Arch git](https://archlinux.org/packages/extra/x86_64/git/))
3. Without a running service, the helper's `secret_service_get_sync` path logs a critical error and fails. ([source](https://raw.githubusercontent.com/git/git/master/contrib/credential/libsecret/git-credential-libsecret.c))
4. Desktop session / unlocked keyring is typically required for interactive unlock; headless servers may need a different helper (`cache`, `store`, or OAuth helpers).

## Configuration

Upstream rule ([gitcredentials](https://git-scm.com/docs/gitcredentials)):

- `credential.helper = libsecret` → executes `git credential-libsecret` (requires the binary on `$PATH` or Git's exec path, e.g. `/usr/libexec/git-core` or `/usr/lib/git-core`).
- Absolute path skips the `git credential-` prefix:
  `credential.helper = /usr/libexec/git-core/git-credential-libsecret`
- Authors should install as `git-credential-$NAME` on PATH/GIT_EXEC_PATH so users can use the short name.

Practical guidance:

| Situation                                                                    | Config                                                                                                     |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| Distro package installed into Git's libexec                                  | `git config --global credential.helper libsecret`                                                          |
| Built in-place under `/usr/share/doc/git/contrib/...` (Debian/Ubuntu common) | Use **full path** to the built binary                                                                      |
| Homebrew                                                                     | Short name if `brew --prefix`/bin is on PATH; else full path from `brew --prefix git-credential-libsecret` |

Verify: `git credential-libsecret` (or full path) with operation `get`/`store`, and `git help -a | grep credential-libsecret`.

## Recommended approach

**Most reliable overall (Linux):**

1. **If the OS has a package** → install it (`dnf`/`zypper`/`apk`/`pacman` as above), ensure a Secret Service provider is running, then:

   ```bash
   git config --global credential.helper libsecret
   ```

2. **Debian/Ubuntu** → install build deps + compile the shipped contrib tree (or upstream tarball), then set `credential.helper` to the resulting binary path (or install into `libexec/git-core` via `make install` and use the short name).
3. **Need one command across many Linux hosts** → `brew install git-credential-libsecret` (Linuxbrew), then configure short name or absolute Homebrew path.
4. **Nix** → `pkgs.git.override { withLibsecret = true; }` and point `credential.helper` at that package's `git-credential-libsecret`.
5. **macOS / Windows** → do **not** prioritize libsecret; use osxkeychain / wincred / GCM per upstream.

**Package-per-distro matrix (quick):**

```text
Fedora/RHEL/Alma/CentOS  →  dnf install git-credential-libsecret
openSUSE                 →  zypper install git-credential-libsecret
Alpine                   →  apk add git-credential-libsecret
Arch/Manjaro             →  pacman -S git libsecret   # binary already in git
Debian/Ubuntu            →  build from /usr/share/doc/git/contrib/credential/libsecret
Any Linux + Homebrew     →  brew install git-credential-libsecret
Nix                      →  git.override { withLibsecret = true; }
```

## Gaps / uncertainties

- **Guix:** no confirmed package name from official Guix package pages in this pass.
- **openSUSE official software.opensuse.org** HTML returned 403 to the fetcher; packaging confirmed via the official Tumbleweed OSS download directory listing instead.
- **mise/asdf/Flatpak/Snap:** absence of hits is a negative result, not a formal "does not exist forever" proof—re-check if those ecosystems add a formula later.
- **RHEL packaging** confirmed via RPM distribution indexes (CentOS Stream / Alma AppStream); Fedora's own packages.fedoraproject.org page listed Fedora releases, not EL, in the overview table.

## Sources

- [Git credential helpers](https://git-scm.com/doc/credential-helpers) — official helper list; libsecret = Linux Secret Service
- [gitcredentials documentation](https://git-scm.com/docs/gitcredentials) — `credential.helper` naming and path rules
- [git/git contrib/credential/libsecret](https://github.com/git/git/tree/master/contrib/credential/libsecret) — upstream location
- [Makefile (raw)](https://raw.githubusercontent.com/git/git/master/contrib/credential/libsecret/Makefile) — build/install deps and paths
- [git-credential-libsecret.c (raw)](https://raw.githubusercontent.com/git/git/master/contrib/credential/libsecret/git-credential-libsecret.c) — Secret Service API usage
- [contrib/README (raw)](https://raw.githubusercontent.com/git/git/master/contrib/README) — contrib status vs core
- [Commit 87d1353](https://github.com/git/git/commit/87d1353a6a133aafd2ef29ba6c740a8d3d71dadb) — introduction of libsecret helper
- [Debian package contents search (sid)](https://packages.debian.org/search?mode=filename&searchon=contents&keywords=git-credential-libsecret&suite=sid) — only `.c` under doc/contrib
- [Debian git filelist (sid)](https://packages.debian.org/sid/armel/git/filelist) — contrib sources path
- [Ubuntu noble git filelist](http://packages.ubuntu.com/noble/all/git/filelist) — same contrib layout
- [Fedora git-credential-libsecret](https://packages.fedoraproject.org/pkgs/git/git-credential-libsecret/) — subpackage
- [Fedora Rawhide files](https://packages.fedoraproject.org/pkgs/git/git-credential-libsecret/fedora-rawhide.html) — `/usr/libexec/git-core/...`
- [Arch Linux git package](https://archlinux.org/packages/extra/x86_64/git/) — optional libsecret / secrets deps
- [Arch git files](https://archlinux.org/packages/extra/x86_64/git/files/) — binary path
- [Arch git PKGBUILD](https://gitlab.archlinux.org/archlinux/packaging/packages/git/-/raw/main/PKGBUILD) — builds and installs helper
- [Alpine package](https://pkgs.alpinelinux.org/package/edge/main/x86_64/git-credential-libsecret) — package name and deps
- [openSUSE Tumbleweed OSS listing](https://download.opensuse.org/tumbleweed/repo/oss/x86_64/) — `git-credential-libsecret-*.rpm`
- [Homebrew formula page](https://formulae.brew.sh/formula/git-credential-libsecret) — Linux/macOS bottles
- [Homebrew formula source](https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/git-credential-libsecret.rb) — builds from contrib
- [nixpkgs git default.nix (release-25.11)](https://github.com/NixOS/nixpkgs/blob/release-25.11/pkgs/applications/version-management/git/default.nix) — `withLibsecret`
- [NixOS Wiki: Git](https://nixos.wiki/wiki/Git) — example credential.helper override (community wiki; points at nixpkgs behavior)
- [libsecret API docs](https://gnome.pages.gitlab.gnome.org/libsecret/) — Secret Service client library
