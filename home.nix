{ config, pkgs, ... }:

let
  local = import ./local.nix;
in {
  home = {
    file = {
      "vimrc".source = ./files/.vimrc;
    };
    homeDirectory = "${local.usersDirectory}/${local.username}";
    stateVersion = "21.05";
    username = "${local.username}";
  };

  programs = {
    exa = {
      enable = true;
      enableAliases = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    home-manager.enable = true;
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      extraConfig = ''
        # Preserve folder
        bind '%' split-window -h -c '#{pane_current_path}'
        bind '"' split-window -v -c '#{pane_current_path}'
        bind c new-window -c '#{pane_current_path}'

        # vi mode
        set-window-option -g mode-keys vi

        # Enable mouse
        set -g mouse on
      '';
      terminal = "screen-256color";
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      initExtra = ''
        bindkey -v
      '';
      shellAliases = {
        ips = "ifconfig | grep -E 'inet ' | awk '{print $2}' | grep -v '127.0.0.1' && curl http://ifconfig.co";
      };
    };
  };
}

