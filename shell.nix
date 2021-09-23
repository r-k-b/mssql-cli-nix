{ pkgs ? import <nixpkgs> { }, mssql-cli }:

pkgs.mkShell {
  name = "mssql-cli-shell";
  buildInputs = with pkgs; [ mssql-cli ];
  shellHook = "";
}
