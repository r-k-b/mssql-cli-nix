# cribbed from https://github.com/NixOS/nixpkgs/blob/a6ce00c50c36624fec06b2b756a766d4d0f4a888/pkgs/applications/version-management/git-and-tools/bump2version/default.nix
{ buildPythonPackage, fetchPypi, isPy27, pytest, testfixtures, mock, lib
, bump2version }:

buildPythonPackage rec {
  pname = "bumpversion";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-S6VeQIDTc/gBd7TavvFGwHznPH0Td6q/nTw64flFhKY=";
  };

  # is bumpversion 0.6.0 just a pointer to bump2version?
  # should we be using 0.5.3?
  checkInputs = [ bump2version ];

  meta = with lib; {
    description = "Version-bump your software with a single command";
    longDescription = ''
      A small command line tool to simplify releasing software by updating
      all version strings in your source code by the correct increment.
    '';
    homepage = "https://github.com/peritus/bumpversion";
    license = licenses.mit;
  };
}
