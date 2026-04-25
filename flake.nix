{
  description = "NixOS Flake: Base Estable + Herramientas Inestables + Antigravity";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; 
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 2. Declaramos la rama INESTABLE de forma aislada
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 3. Repositorio de tu IDE
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs: 
    let
      system = "x86_64-linux";
      
      # Instanciamos la colección inestable permitiendo software propietario
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      
      # Pasamos tanto 'inputs' como 'unstablePkgs' al resto del sistema (configuration.nix)
      specialArgs = { inherit inputs unstablePkgs; };
      
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.jirevelaz = import ./home.nix;
        }
      ];
    };
  };
}
