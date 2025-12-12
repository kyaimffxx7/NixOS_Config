# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # home-manager
      # inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable IP forwarding
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  #  "net.ipv6.conf.all.forwarding" = 1
  };

  # AMDGPU setup
  ## move to hardware-configuration.nix
  # boot.initrd.kernelModules = [ "amdgpu" ];

  # Newest packages
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Wifi driver setup
  hardware.enableRedistributableFirmware = true;
  ## move to hardware-configuration.nix
  # boot.kernelModules = [ "rtw89" ];

  # Bluetooth setting
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Enable hyprland Cachix
  # nix.settings = {
  #   substituters = ["https://hyprland.cachix.org"];
  #   trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  # };

  # Insecure Packages Setting
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
    "openssl-1.1.1w"
  ];


  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  services.upower.enable = true;
  # Enable networking
  networking.networkmanager.enable = true;
  
  # Add substituters from tsinghua mirror site
  # nix.settings.substituters = lib.mkForce [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  # nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  # Storage optimization
  nix.optimise.automatic = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_HK.UTF-8";
  
  # Input method setup
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-configtool
      qt6Packages.fcitx5-chinese-addons
      qt6Packages.fcitx5-qt
    ];
  };

  # Fonts setting
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    maple-mono.truetype
    maple-mono.NF-unhinted
    maple-mono.NF-CN-unhinted
    
  ];
  
  # For AMDGPU
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable KDE plasma 6.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  # Ly
  # services.displayManager.ly.enable = true;

  # # Enable hyprland
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  #   # make sure to also set the portal package, so that they are in sync
  #   portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  # };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  #############################
  ## Programs configurations ##
  #############################
  ## Zsh 
  programs.zsh = {
    enable = false;
    autosuggestions.enable = false;
    enableCompletion = false;
    syntaxHighlighting.enable = false;
    shellAliases = {
      ll = "ls -alh";
    };
  };

  ## fish + starship
  programs.fish = {
    enable = true;
  };
  programs.starship = {
    enable = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      # add_newline = false;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };

      # package.disabled = true;
    };
  };

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "kyaimffxx7";
        email = "mask2live@gmail.com";
      };
    };
    lfs.enable = true;
  };

  ### kdeconnect ###
  programs.kdeconnect.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hisoka = {
    isNormalUser = true;
    description = "hisoka";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" "disk" "input" "docker" ]; # if enable docker, add "docker"
    packages = with pkgs; [
      chromium
    ];
  };

  # home-manager setup
  # home-manager = {
  #   extraSpecialArgs = { inherit inputs; };
  #   users = {
  #     "hisoka" = import ./home.nix;
  #   };
  # };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow Unsupported system
  nixpkgs.config.allowUnsupportedSystem = true;

  # Emacs requiremet
  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball https://github.com/nix-community/emacs-overlay/archive/master.tar.gz))
  # ];

  ######################
  #   Virtualisation   #
  ######################
  # Docker setup
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Virtual machine setup
  virtualisation.libvirtd = {
  	enable = true;
  	qemu = {
  	  package = pkgs.qemu_kvm;
  	  runAsRoot = true;
  	  swtpm.enable = true;
  	};
  };
  programs.virt-manager.enable = true;

  
  ## Flatpak
  # services.flatpak.enable = true;
  ## Emacs
  services.emacs.enable = true;
  ## Dae
  # services.dae.enable = true;
  # services.dae.configFile = "/usr/local/dae/config.dae";
  ## V2raya
  # services.v2raya.enable = true;
  # services.v2ray.enable = true;

  #########################
  # Packages Installation #
  #########################
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ############
    # Terminal #
    ############
    termius
    ghostty

    ###########
    # Editors #
    ###########
    # Emacs
    emacs
    ripgrep
    coreutils
    fd
    clang
    
    # IDEs
    zed-editor
    helix
    #andrd-studio
    jetbrains-toolbox

    # Office
    libreoffice-still

    # Note & Reader
    anytype
    appflowy
    calibre

    # Internet tools
    wget
    curl
    git
    dnsmasq
    ebtables

    # browser
    brave
    tor-browser

    # Video & Picture Editor
    gimp
    krita


    # File tool
    kdePackages.filelight
    
    # Zsh plugins
    # zsh-autosuggestions
    # zsh-syntax-highlighting
    # zsh-completions
    #
    starship

    # Compilers & Interpreter
    gcc
    gnumake

    #janet
    #jpm

    # hyprland utilities
    # wofi
    # waybar
    # mako
    # libnotify
    # swww
    # networkmanagerapplet
    # grim
    # slupr
    # wl-clipboard
    # wlogout
    # hypridle
    # hyprlock
    # pavucontrol
    # blueman

    # tools
    fastfetch
    tree
    file
    nmap
    btop
    pciutils
    inxi
    autoPatchelfHook
    tmux
    unzip
    devenv
    # doomemacs necessary
    cmake
    libtool
    emacsPackages.nixfmt
    # Python3
    # python313
    #
    # # LSP
    # ruff
    # prettier
    # rust-analyzer
    rustup
    nodejs_24

    # Video tools
    kdePackages.kdenlive
    # shotcut
    obs-studio
    # player
    haruna
    
    # Communications
    telegram-desktop
    discord

    # Notes
    obsidian

    # DB management
    dbeaver-bin

    # Collab
    feishu

    # NixOS home-manager
    # home-manager

    # sddm theme
    sddm-astronaut

  ];

  environment.variables = {
  	
  };

  environment.sessionVariables = {
    # cursor visible settings
    WLR_NO_HARDWARE_CURSORS = "1";

    # electron apps in wayland
    NIXOS_OZONE_WL = "1";    
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
