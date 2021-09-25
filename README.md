Makes the [mssql-cli] tool available as a Nix Flake.

[mssql-cli]: https://github.com/dbcli/mssql-cli

# usage

```shell
$ nix run github:r-k-b/mssql-cli-nix#cli
```

# debugging the build

```shell
$ nix develop

$ rm -rf outputs source

# stay in the shell when a command fails (setup sets -e)
$ source $stdenv/setup && set +e

$ unpackPhase

$ cd source

$ patchPhase

# why does running `$ configurePhase` not use the steps in the derivation!?
$ eval "$configurePhase"

# why does running `$ buildPhase` not use the steps in the derivation!?
$ eval "$buildPhase"

$ eval "$checkPhase"

$ eval "$installPhase"
```

See [6.5.1.1.1] for a reference on the available phases.

[6.5.1.1.1]: https://nixos.org/manual/nixpkgs/stable/#ssec-controlling-phases