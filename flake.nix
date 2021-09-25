{
  description =
    "A command-line client for SQL Server with auto-completion and syntax highlighting";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.source = {
    url = "github:dbcli/mssql-cli";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, source }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib callPackage stdenv;

        pythonPackages = pkgs.python3Packages;

        mssql-cli = import ./default.nix {
          inherit lib pkgs pythonPackages source stdenv;
          tree = pkgs.tree;
        };
      in {
        defaultPackage = mssql-cli;
        devShell = import ./shell.nix { inherit mssql-cli pkgs; };
        #packages = { inherit mssql-cli; };
      });
}
