#!/usr/bin/env bash
set -e

# Install nix
sh <(curl -L https://nixos.org/nix/install)
. $HOME/.nix-profile/etc/profile.d/nix.sh
if [[ "$OSTYPE" == "darwin"* ]]; then
  nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
  ./result/bin/darwin-installer
  rm -rf ./result
fi

# Install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
nix-shell '<home-manager>' -A install

# Clone, link and run
if [ -d "$HOME/.dotnix" ] 
then
  echo "Skipping clone to .dotnix" 
else
  git clone https://github.com/allanbreyes/dotnix.git $HOME/.dotnix
fi
ln -sf $HOME/.dotnix/vars.example.nix $HOME/.dotnix/vars.nix
ln -sf $HOME/.dotnix/home.nix $HOME/.config/nixpkgs/home.nix
if [[ "$OSTYPE" == "darwin"* ]]; then
  ln -sf $HOME/.dotnix/darwin.nix $HOME/.nixpkgs/darwin-configuration.nix
  darwin-rebuild switch
else
  home-manager switch
fi
