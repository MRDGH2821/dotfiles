#!/usr/bin/env bash
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=\"${XDG_CONFIG_HOME}\"/java"
export npm_config_cache="${XDG_CACHE_HOME}/npm"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"
export GTK2_RC_FILES="${XDG_CONFIG_HOME}/gtk-2.0/gtkrc"
export PSQL_HISTORY="${XDG_DATA_HOME}/psql_history"
