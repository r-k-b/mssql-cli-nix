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

        pythonPackages = (pkgs.python3.override {
          packageOverrides = self: super: {
            self = pythonPackages;

            # not compatible with click >=7.1
            # override is based on <https://github.com/NixOS/nixpkgs/commit/4588e6a0cd249a1358d99388d4f6a0725de96f99>
            click = super.click.overridePythonAttrs (oldAttrs: rec {
              name = "${oldAttrs.pname}-${version}";
              version = "7.0";
              src = oldAttrs.src.override {
                inherit version;
                sha256 =
                  "5b94b49521f6456670fdb30cd82a4eca9412788a93fa6dd6df72c94d5a8ff2d7";
              };
              postPatch = ''
                substituteInPlace click/_unicodefun.py \
                  --replace "'locale'" "'${pkgs.locale}/bin/locale'"
              '';
            });

            bump2version = pythonPackages.callPackage ./bump2version.nix { };
            bumpversion = pythonPackages.callPackage ./bumpversion.nix { };
          };
        }).pkgs;

        mssql-cli = import ./default.nix {
          inherit lib pkgs pythonPackages source stdenv;
          tree = pkgs.tree;
        };
      in { defaultPackage = mssql-cli; });

  nixConfig.bash-prompt = "[mssqlcli]$ ";
}
