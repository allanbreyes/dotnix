{ config, pkgs, ... }:

let
  local = import ./local.nix;
in {
  home = {
    file = {
      "vimrc".source = ./files/.vimrc;
    };
    homeDirectory = "${local.usersDirectory}/${local.username}";
    packages = with pkgs; [
      age
      colordiff
      curl
      dnsutils
      docker-compose
      gcc
      go
      file
      htop
      jetbrains.idea-ultimate
      jq
      kubectl
      logseq
      nettools
      python3
      spotify
      sops
      terraform
      tldr
      tree
      unzip
      vagrant
      vim
      wget
    ];
    stateVersion = "21.05";
    username = "${local.username}";
  };

  programs = {
    home-manager.enable = true;

    exa = {
      enable = true;
      enableAliases = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
    };
    git = {
      enable = true;
      aliases = {
        cm = "commit -m";
        co = "checkout";
        lg = "log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
        st = "status";
        undo = "reset --soft HEAD^";
        unstage = "reset HEAD --";
      };
      extraConfig = {
        apply.whitespace = "nowarn";
        color = {
          diff = "auto";
          status = "auto";
          branch = "auto";
          ui = "auto";
        };
        credential.helper = "cache";
        help.autocorrect = 1;
        init.defaultBranch = "main";
        pull.ff = "only";
        push.default = "simple";
        url = {
          "git@github.com" = { insteadOf = "gh:"; };
        };
      };
      ignores = [
        "*.swp"
        "*~"
        "#*"
        ".DS_Store"
      ];
      signing = {
        key = "${local.gpgSigningKey}";
        signByDefault = true;
      };
      userName = "${local.fullName}";
      userEmail = "${local.githubUsername}@users.noreply.github.com";
    };
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
      history.extended = true;
      initExtra = ''
        bindkey -v
      '';
      sessionVariables = {
        EDITOR = "vim";
      };
      shellAliases = {
        ips = "ifconfig | grep -E 'inet ' | awk '{print $2}' | grep -v '127.0.0.1' && curl http://ifconfig.co";
        k = "kubectl";
        switch = "home-manager switch && source ~/.zshrc";
      };
    };
  };
}

