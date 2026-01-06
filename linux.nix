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
      graphite-gtk-theme
      libusb1
      mate.engrampa
      networkmanager
      openjdk
      openssl
      pavucontrol
      rtl-sdr
      seahorse
      tailscale
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xfce.xfce4-power-manager
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-systemload-plugin
      xfce.xfce4-weather-plugin
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  hardware = {
    bluetooth.enable = true;
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
        config.services.tailscale.port
        21027  # Syncthing
        22000  # Syncthing
      ];
      checkReversePath = "loose";
      enable = true;
      trustedInterfaces = ["tailscale0"];
    };
    networkmanager.enable = true;
    useDHCP = false;
    wireless.enable = false;
  };

  nix = {
    settings = {
      allowed-users = ["${vars.username}"];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };
    package = pkgs.nixVersions.latest;
  };

  nixpkgs.config = import ./config.nix;

  programs = {
    firejail = let
      bins = [
        "chromium"
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
  };

  services = {
    blueman.enable = true;
    compton.enable = true;
    displayManager.defaultSession = "xfce";
    gnome.gnome-keyring.enable = true;
    gvfs = {
      enable = true;
      package = lib.mkForce pkgs.gnome.gvfs;
    };
    libinput.enable = true;
    opensnitch.enable = true;
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
    tailscale.enable = true;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNER_ON_BAT = "powersave";
        CPU_MAX_PERF_ON_BAT = 60;
      };
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
    };
  };

  system.autoUpgrade = {
    allowReboot = false;
    enable = true;
  };

  # HACK: https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = with pkgs; ''
      # Wait for tailscaled to settle
      sleep 2

      # Check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # Otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up --accept-routes=false --auth-key=${vars.tailscaleAuthKey}
    '';
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
