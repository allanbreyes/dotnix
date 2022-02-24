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
    };
    homeDirectory = "${vars.usersDirectory}/${vars.username}";
    packages = with pkgs; [
      # Common packages
      age
      ansible
      colordiff
      curl
      dnsutils
      docker-compose
      file
      gcc
      gnumake
      gping
      htop
      httpie
      jq
      kubectl
      python3
      ripgrep
      sops
      terraform
      tldr
      tree
      unzip
      vagrant
      vim
      wget
      yamllint
    ] ++ (if stdenv.isDarwin then [
      # macOS packages
    ] else [
      # Linux packages
      evince
      gimp
      gqrx
      jetbrains.idea-ultimate
      libreoffice
      logseq
      moonlight-qt
      nettools
      packer
      simple-scan
      spotify
      thunderbird
      ticker
      transgui
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

  nixpkgs.config = import ./config.nix;

  programs = {
    home-manager.enable = true;

    bat.enable = true;
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
      history.extended = true;
      initExtra = builtins.readFile ./files/init.zsh;
      sessionVariables = {
        EDITOR = "vim";
      };
      shellAliases = {
        cat = "bat";
        clip = if stdenv.isDarwin then "pbcopy" else "xclip -selection clipboard";
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
