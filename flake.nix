{
  description = "A command-line client for SQL Server with auto-completion and syntax highlighting";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.source = {
    url = "github:dbcli/mssql-cli";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, source }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib callPackage;

        pythonPackages = pkgs.python3Packages;

        mssql-cli = import ./default.nix { inherit lib pythonPackages source; };
      in {
        devShell = import ./shell.nix { inherit mssql-cli pkgs; };
        packages = { inherit mssql-cli; };
      });
}
