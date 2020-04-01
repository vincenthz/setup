#/usr/bin/env bash

cask_important_pkgs=(
    google-chrome
    visual-studio-code
    hyper
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
    github
    keybase
    openemu
    tla-plus-toolbox
    krita
    libreoffice
    sage
    tor-browser
    hyper
    telegram
)

brew_pkgs=(
    cmake
    findutils
    go
    gpg
    grpcurl
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
    wget
    pandoc
    pinentry-mac
    wireguard-tools
    cocoapods
    qemu
    idris
    graphviz
    ocaml
    opam
    #fstar -- doesn't exist anymore :(
    z3
    github/gh/gh
)

brew_imagemagick="imagemagick --with-webp"

java_cask=(
    java
)

java_pkgs=(
    scala
    sbt
)

if [ ! -f common.sh ]; then
    echo "missing common.sh script"
    exit 2
fi
source common.sh

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
    # Press and Hold
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
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

cmd_latex() {
    util_assert_brew
    brew cask install mactex
}

cmd_rust() {
    if test ! $(which rustup); then
        installing "rust"
        curl https://sh.rustup.rs -sSf | sh
        source $HOME/.cargo/env
    fi

    rustup install nightly
    rustup component add rustfmt-preview
    rustup component add rls
    rustup component add rust-docs
    rustup default stable

    rustup update
}

cmd_machine() {
    git config --global user.name "Vincent Hanquez"
    git config --global user.email "vincent@typed.io"
    git config --global credential.helper osxkeychain

    if [ ! -f ~/.ssh/id_ed25519 ]; then
        ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
    fi
    cat ~/.ssh/id_ed25519.pub
}

cmd_dotfile() {
    echo ""
}

cmd_haskell_preload() {
    if test ! $(which stack); then
        echo "error: stack not installed"
        exit 1
    fi

    pushd /tmp
    stack new dummy
    cd dummy
    stack build
}

case $1 in
    "system") cmd_system;;
    "system-setup") cmd_system_setup;;
    "brew") cmd_brew;;
    # setup git and ssh for this machine
    "machine") cmd_machine;;
    "java") cmd_java;;
    "rust") cmd_rust;;
    "code") cmd_code;;
    "atom") cmd_atom;;
    "latex") cmd_latex;;
    "haskell") cmd_haskell_preload;;
    "rust-programs") cmd_rust_install;;
    "")
        echo "usage: $0 <system|system-setup|brew|machine|rust|java|code|atom|haskell|rust-programs>"
        ;;
esac
