#/usr/bin/env bash

cask_important_pkgs=(
    google-chrome
    visual-studio-code
)

cask_after_pkgs=(
    spectacle
    slack
    transmission
    transmission-remote-gui
    tunnelbear
    atom
    dropbox
    docker
    keybase
)

brew_pkgs=(
    go
    gpg
    haskell-stack
    htop
    mpv
    nmap
    neovim
    node
    tmux
    tig
    tree
    zola
    pandoc
)

brew_imagemagick="imagemagick --with-webp"

java_cask=(
    java
)

java_pkgs=(
    scala
    sbt
)

vscode_exts=(
  vscodevim.vim
  rust-lang.rust
  alanz.vscode-hie-server
  yzhang.markdown-all-in-one
)

########################################################

RED="\033[1;31m"
WHI="\033[0m"

installing() {
    echo -e "${RED}Installing${WHI} $1 ..."
}
updating() {
    echo -e "${RED}Updating${WHI} $1 ..."
}

util_sudo_keepalive() {
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

util_assert_brew() {
    if test ! $(which brew); then
        installing "brew"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
}


cmd_system() {
    util_sudo_keepalive
    sudo softwareupdate -ia
    xcode-select --install
}

cmd_system_setup() {
    sudo nvram SystemAudioVolume=" "
    # Disable natural scrolling
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
}

cmd_brew() {
    util_assert_brew

    updating "brew"
    brew update
    brew upgrade --all

    updating "brew cask"
    brew tap caskroom/cask

    brew cask install --appdir="/Applications" ${cask_important_pkgs[@]}
    brew install ${brew_pkgs[@]}
    brew install ${brew_imagemagick}
    brew cask install --appdir="/Applications" ${cask_after_pkgs[@]}
}

cmd_java() {
    util_assert_brew

    brew cask install ${java_cask[@]}
    brew install ${java_pkgs[@]}
}

cmd_rust() {
    if test ! $(which rustup); then
        installing "rust"
        curl https://sh.rustup.rs -sSf | sh
    fi

    rustup install nightly
    rustup component add rustfmt-preview
    rustup component add rls
    rustup component add rust-docs
    rustup default nightly

    rustup update
}

cmd_machine() {
    git config --global user.name "Vincent Hanquez"
    git config --global user.email "vincent@typed.io"
    git config --global credential.helper osxkeychain

    if [ -f ~/.ssh/id_ed25519 ]; then
        ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
    fi
    cat ~/.ssh/id_ed25519.pub
}

cmd_code() {
    if test ! $(which code); then
	echo "code not installed"
	exit 1
    fi
    for ext in ${vscode_exts[@]}
    do code --install-extension ${ext}; done
}

cmd_dotfile() {
    echo ""
}

case $1 in
  "system") cmd_system;;
  "system-setup") cmd_system_setup;;
  "brew") cmd_brew;;
  "machine") cmd_machine;;
  "java") cmd_java;;
  "rust") cmd_rust;;
  "code") cmd_code;;
  "")
    echo "usage: $0 <system|system-setup|brew|rust|java>"
    ;;
esac
