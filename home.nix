{ config, lib, pkgs, ... }:

let
  nixpkgs = import <nixpkgs> {};
  vars = if (builtins.pathExists ./vars.nix) then import ./vars.nix else {};
  inherit (nixpkgs) stdenv;
in {
  imports = [
  ] ++ lib.optional (builtins.pathExists ./home.local.nix) ./home.local.nix;

  home = {
    file = {
      ".vimrc".source = ./files/vimrc;
      ".local/bin/kv".source = ./files/scripts/kv.sh;
    };
    homeDirectory = "${vars.usersDirectory}/${vars.username}";
    packages = with pkgs; [
      # Common packages
      age
      ansible
      aws-vault
      awscli
      cargo
      colordiff
      curl
      delve
      docker
      docker-compose
      file
      gcc
      gh
      git
      gnumake
      gnupg
      gping
      htop
      httpie
      jq
      nixops
      nmap
      python3
      rename
      ripgrep
      rustc
      rustfmt
      sops
      swig
      terraform
      terraform-ls
      tldr
      tree
      unzip
      vagrant
      virtualenv
      watch
      wget
      wireguard-go
      wireguard-tools
      yamllint
      yarn
    ] ++ (if stdenv.isDarwin then [
      # macOS packages
      pinentry_mac
    ] else [
      # Linux packages
      dnsutils
      evince
      firefox
      gimp
      gqrx
      libreoffice
      logseq
      moonlight-qt
      nettools
      packer
      powertop
      signal-desktop
      simple-scan
      spotify
      thunderbird
      ticker
      transgui
      vscode
      xclip
      zap
      zotero
    ]);
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
    ];
    stateVersion = "21.05";
    username = vars.username;
  };

  nixpkgs = {
    config = import ./config.nix;
    overlays = [];
  };

  programs = {
    home-manager.enable = true;

    bat.enable = true;
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };
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
      delta = {
        enable = true;
        options = {
          line-numbers = true;
          navigate = true;
        };
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
        push.autoSetupRemote = "true";
        push.default = "simple";
        url = {
          "git@github.com:" = { insteadOf = "gh:"; };
        };
      };
      ignores = [
        "*.swp"
        "*~"
        "#*"
        ".DS_Store"
        ".envrc"
      ];
      signing = {
        key = vars.gpgSigningKey;
        signByDefault = true;
      };
      userName = vars.fullName;
      userEmail = vars.gitEmail;
    };
    go = {
      enable = true;
      goPath = "go";
    };
    neovim = {
      enable = true;
      extraConfig = builtins.readFile ./files/vimrc;
      plugins = with nixpkgs.vimPlugins; [
      ];
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      extraConfig = builtins.readFile ./files/tmux.extra.conf;
      terminal = "screen-256color";
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      history = {
        extended = true;
        ignorePatterns = ["export *"];
      };
      initExtra = builtins.readFile ./files/init.zsh;
      sessionVariables = {
        EDITOR = "vim";
      };
      shellAliases = {
        cat = "bat";
        clip = if stdenv.isDarwin then "pbcopy" else "xclip -selection clipboard";
        gd = "cd \"$(git rev-parse --show-toplevel)\"";
        ips = "ifconfig | grep -E 'inet ' | awk '{print $2}' | grep -v '127.0.0.1' && curl http://ifconfig.co";
        k = "kubectl";
        o = if stdenv.isDarwin then "open" else "xdg-open";
        switch = if stdenv.isDarwin
          then "darwin-rebuild switch"
          else "sudo nixos-rebuild switch --upgrade";
      };
    };
  };
}
