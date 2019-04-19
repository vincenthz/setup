#!/bin/bash

vscode_exts=(
  vscodevim.vim
  rust-lang.rust
  alanz.vscode-hie-server
  yzhang.markdown-all-in-one
  bungcip.better-toml
  makarius.isabelle
  james-yu.latex-workshop
  josser.language-fstar
)

atom_exts=(
  vim-mode-plus  
  teletype
)

cargo_program_exts=(
  cargo-tree
  count
)

cmd_code() {
    if test ! $(which code); then
        echo "error: code not installed"
        exit 1
    fi
    for ext in ${vscode_exts[@]}
    do code --install-extension ${ext}; done
}

cmd_atom() {
    if test ! $(which atom); then
        echo "error: atom not installed"
        exit 1
    fi
    if test ! $(which apm); then
        echo "error: atom package manager (apm) not installed"
        exit 1
    fi
    for ext in ${atom_exts[@]}
    do apm install ${ext}; done
}

cmd_rust_install() {
    if test ! $(which cargo); then
        echo "error: cargo package manager not installed"
        exit 1
    fi
    for ext in ${cargo_program_exts[@]}
    do cargo install ${ext}; done
}
