{ config, lib, pkgs, ... }:

let
  nixpkgs = import <nixpkgs> {};
  unstable = import <nixos-unstable> {};
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
      awscli2
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
      magic-wormhole
      mongosh
      nmap
      pass
      postgresql
      pre-commit
      python3
      redis
      rename
      ripgrep
      rustfmt
      sops
      swig
      terraform
      terraform-ls
      tldr
      tree
      unzip
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
      calibre
      dnsutils
      evince
      firefox
      gimp
      google-chrome
      gqrx
      libreoffice
      logseq
      nettools
      obsidian
      packer
      powertop
      signal-desktop
      simple-scan
      slack
      spotify
      thunderbird
      ticker
      transgui
      vagrant
      vscode
      xclip
      zap
      zotero

      # Unstable packages
      unstable.moonlight-qt
      unstable.rustc
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
    eza = {
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
      syntaxHighlighting.enable = true;
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
        ips = "ifconfig | grep -E 'inet ' | awk '{print $2}' | grep -v '127.0.0.1' && curl http://ifconfig.me";
        k = "kubectl";
        o = if stdenv.isDarwin then "open" else "xdg-open";
        switch = if stdenv.isDarwin
          then "darwin-rebuild switch"
          else "sudo nixos-rebuild switch --upgrade";
        uuid = "python -c 'import uuid; print(uuid.uuid4())'";
      };
    };
  };
  services = {
    opensnitch-ui.enable = stdenv.isLinux;
  };
}
