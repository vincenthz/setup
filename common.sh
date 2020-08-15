#!/bin/bash

vscode_exts=(
	bungcip.better-toml
	forivall.abnf
	GitHub.vscode-pull-request-github
	haskell.haskell
	James-Yu.latex-workshop
	josser.language-fstar
	justusadam.language-haskell
	makarius.Isabelle
	matklad.rust-analyzer
	ms-vscode.cpptools
	ms-vscode.hexeditor
	mtxr.sqltools
	redhat.java
	scala-lang.scala
	truefire.lilypond
	VisualStudioExptTeam.vscodeintellicode
	vscodevim.vim
	yzhang.markdown-all-in-one
	zxh404.vscode-proto3
)

atom_exts=(
  vim-mode-plus  
  teletype
)

cargo_program_exts=(
  cargo-tree
  cargo-expand
  count
  mdbook
  diesel_cli
  cbindgen
  bat
  wasm-nm
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
