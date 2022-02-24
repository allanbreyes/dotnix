{ config, lib, pkgs, ... }:

let
  vars = if (builtins.pathExists ./vars.nix) then import ./vars.nix else {};
in {
  imports = [
    <home-manager/nix-darwin>
  ] ++ lib.optional (builtins.pathExists ./darwin.local.nix) ./darwin.local.nix;

  environment.systemPackages = with pkgs; [
    gnupg
    pinentry_mac
  ];

  fonts = with pkgs; {
    enableFontDir = true;
    fonts = [(nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })];
  };

  home-manager = {
    users.${vars.username} = import ./home.nix;
  };

  nix.package = pkgs.nix;

  programs.zsh.enable = true;

  services.nix-daemon.enable = true;

  system.stateVersion = 4;

  users.users.${vars.username} = {
    name = vars.username;
    home = "${vars.usersDirectory}/${vars.username}";
  };
}
