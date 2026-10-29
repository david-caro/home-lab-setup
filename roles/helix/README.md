# Helix

Installs Helix and all configured language servers separately for each account
in `helix_users`. This defaults to the repository's `users` list, or the
connection user when that list is absent. Accounts must already
exist. Home directories are read from passwd, including custom home paths.

All executables are installed or linked in the selected user's `~/bin`.
Add that directory to the user's PATH before launching `hx`.

The personal playbook includes this role. To run only Helix setup:

```sh
ansible-galaxy collection install community.general
ansible-playbook plays/continuous/02-personal.yaml --tags helix --limit hephaestus -K
```

Replace the host name as needed. To use the role in another playbook:

```yaml
- hosts: personal
  roles:
    - role: helix
      helix_users:
        - name: dcaro
```

Tasks run as the selected account with its HOME and PATH set explicitly.
Installing for the connection user needs no privilege escalation; installing
for other users requires permission to become those accounts. Fact gathering
and the `community.general` collection are required. Tags are `helix` and `coding`.

The default installation makes no system package changes. It assumes Cargo,
a C/C++ build toolchain, OpenSSL development headers, Go, Node/npm, Python
with pip/venv, Ruby/RubyGems, tar, xz, unzip, and gzip are available. Set
`helix_install_system_dependencies: true` to install these Fedora dependencies
with root privileges. Override `helix_system_packages` for other distributions.

Installation locations:

- Helix, clangd, and harper-ls: release archives under `~/.local/share/helix/`, with
  executable links in `~/bin`. Helix's bundled runtime is linked at
  `~/.config/helix/runtime`. Harper uses an upstream prebuilt release instead
  of compiling harper-core.
- rust-analyzer: release binary under `~/.local/share/helix/`, linked in `~/bin`.
- npm servers: prefix `~/.local/share/helix/node_lsps`, placing packages in
  its `lib/node_modules` directory and linking its commands into `~/bin`.
- Python servers: isolated environment at `~/.local/share/helix/python`, with
  `djlsp`, `ty`, `ruff`, and `pylsp` linked in `~/bin`.
  This environment also provides ansible-core, ansible-lint, and yamllint.
  The Ansible server command in `~/bin` is a wrapper that prepends this
  environment to PATH so its Python interpreter and Ansible tools agree.
- Cargo servers: install root `~/.local/share/helix/cargo_lsps`, with
  executables in its `bin` directory linked into `~/bin`. Markdown-oxide
  is installed from its upstream Git repository; other packages use crates.io.
  Cargo package entries may specify a `git` URL to select a Git source.
- Go servers: `GOBIN=~/.local/share/helix/go_lsps/bin`, with executables
  linked into `~/bin`, including the `helm_ls` alias for `helm-ls`.
  Installation uses `GOTOOLCHAIN=auto` so Go can download a newer compiler
  when a server requires it. Override `helix_go_toolchain` to change this
  behavior. This setting applies only to the installation task.
- ruby-lsp: user gem installation with executables in `~/bin`. Uses
  `gem install` directly to support RubyGems versions without `gem query`;
  installation is skipped when `~/bin/ruby-lsp` already exists.
- Marksman: downloaded directly to `~/bin`.

Package lists and download sources are configurable in `defaults/main.yaml`.
Helix, rust-analyzer, and Marksman support x86_64 and aarch64 Linux; the
upstream clangd archive selected by default requires x86_64. Override
`helix_release_packages` to use a suitable clangd build on other architectures.

The first run downloads releases and compiles Cargo/Go servers. Existing
release, Cargo, and Go binaries are retained on subsequent runs. To reinstall
a release, remove its link from `~/bin` and its directory under
`~/.local/share/helix/`. To reinstall a Cargo/Go server, remove its binary
from `~/.local/share/helix/cargo_lsps/bin` or
`~/.local/share/helix/go_lsps/bin`. On the next run, existing Cargo/Go binaries
in `~/bin` are replaced with links after installation at the new location.
Versions are not pinned by default. Previous system-wide
installations are left in place.

`texlab-lsp` in the supplied `languages.toml` is an alias for `texlab`.
The role copies `files/languages.toml` to each selected user's
`~/.config/helix/languages.toml`, configuring Harper, LaTeX, Git commits,
and Markdown. The configuration uses Zathura for LaTeX forward search;
install Zathura separately if needed. The role also copies `files/config.toml`
to `~/.config/helix/config.toml`, enabling the `dark_high_contrast` theme,
soft wrapping, and the custom status line. Changes to these deployed files
are overwritten by the next role run; edit the role's source files to keep
configuration changes.

After installation, ensure `~/bin` is on PATH and check server availability:

```sh
export PATH="$HOME/bin:$PATH"
hx --health yaml
hx --health markdown
```

These checks confirm that executables and editor support files are available;
they do not verify that a language server stays running. Restart Helix after
rerunning the role to use updated tools and configuration.
