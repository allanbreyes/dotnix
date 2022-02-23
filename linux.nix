{ config, lib, pkgs, ... }:

let
  vars = if (builtins.pathExists ./vars.nix) then import ./vars.nix else {};
in {
  imports = [
    <home-manager/nixos>
    /etc/nixos/hardware-configuration.nix
  ] ++ lib.optional (builtins.pathExists ./linux.local.nix) ./linux.local.nix;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  console = {
    font = "Fira Code";
    keyMap = "us";
  };

  environment = {
    shellInit = ''
      export GPG_TTY="$(tty)"
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
    '';
    systemPackages = with pkgs; [
      autofs5
      clamav
      gnupg1
      libusb
      lightlocker
      mate.engrampa
      networkmanager
      openjdk
      openssl
      pavucontrol
      rtl-sdr
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xfce.xfce4-power-manager
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-systemload-plugin
      xfce.xfce4-weather-plugin
    ];
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  hardware = {
    pulseaudio.enable = true;
    rtl-sdr.enable = true;
  };

  home-manager.users.${vars.username} = import ./home.nix;

  i18n.defaultLocale = "en_US.UTF-8";

  location.provider = "geoclue2";

  networking = {
    firewall = {
      allowedTCPPorts = [
        22000  # Syncthing
      ];
      allowedUDPPorts = [
        21027  # Syncthing
        22000  # Syncthing
      ];
      enable = true;
    };
    networkmanager.enable = true;
    useDHCP = false;
    wireless.enable = false;
  };

  nix = {
    allowedUsers = ["${vars.username}"];
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config = import ./config.nix;

  programs = {
    firejail = let
      bins = [
        "firefox"
      ];
    in {
      enable = true;
      wrappedBinaries = lib.genAttrs bins (bin: 
        {
          executable = "${lib.getBin pkgs.${bin}}/bin/${bin}";
          profile = "${pkgs.firejail}/etc/firejail/${bin}.profile";
        }
      );
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    light.enable = true;
    ssh.startAgent = false;
    steam.enable = true;
    zsh.enable = true;
  };

  security = {
    apparmor.enable = true;
    pam = {
      services.login.fprintAuth = true;
      yubico = {
        control = "required";
        enable = true;
        mode = "challenge-response";
      };
    };
  };

  services = {
    compton.enable = true;
    fprintd.enable = true;
    gvfs = {
      enable = true;
      package = lib.mkForce pkgs.gnome3.gvfs;
    };
    openssh.enable = false;
    pcscd.enable = true;
    redshift = {
      enable = true;
      brightness = {
        day = "1";
        night = "1";
      };
      temperature = {
        day = 5500;
        night = 3700;
      };
    };
    syncthing = {
      enable = true;
      user = vars.username;
      dataDir = "/home/${vars.username}/Sync";
      configDir = "/home/${vars.username}/.config/syncthing";
    };
    udev = {
      packages = with pkgs; [
        rtl-sdr
        yubikey-personalization
      ];
    };
    xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };
      displayManager.defaultSession = "xfce";
      libinput.enable = true;
    };
  };

  sound.enable = true;

  system.autoUpgrade = {
    allowReboot = false;
    enable = true;
  };

  time.timeZone = "America/New_York";

  users.users.${vars.username} = {
    extraGroups = [
      "audio"
      "docker"
      "lp"
      "plugdev"
      "scanner"
      "vboxusers"
      "video"
      "wheel"
    ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  virtualisation = {
    docker.enable = true;
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };

  system.stateVersion = "21.05";
}
