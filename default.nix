{ lib, pkgs, pythonPackages, source, stdenv, tree }:
let
  pname = "mssql-scripter";
  version = "1.0.0";

  sqltoolsservice-release = "v3.0.0-release.72";

  archiveFrom = { folder, file, sha256 }: {
    archive = pkgs.fetchzip {
      url = "https://github.com/microsoft/sqltoolsservice/releases/download/"
        + "${sqltoolsservice-release}/${file}";
      stripRoot = false;
      inherit sha256;
    };
    name = file;
    inherit folder;
  };

  sqlTools = {
    manylinux = archiveFrom {
      folder = "manylinux1";
      file = "Microsoft.SqlTools.ServiceLayer-rhel-x64-netcoreapp3.1.tar.gz";
      sha256 = "sha256-I87uOspXWIyy14mKKx6TCID4UHi3EYON1RyD0s8N04s=";
    };
  };
in pythonPackages.buildPythonApplication {
  inherit pname version;

  src = source;
  #pythonPackages.fetchPypi {
  #  inherit pname version;
  #  sha256 = "0gs791yb0cndg9879vayvcj329jwhzpk6wrf9ri12l5hg8g490za";
  #};

  # Compile-time dependencies
  nativeBuildInputs = (with pkgs; [ git less ]) ++ (with pythonPackages; [
    applicationinsights
    azure-common
    azure-core
    azure-nspkg
    azure-storage
    bump2version
    bumpversion
    cli-helpers
    click
    configobj
    coverage
    docutils
    flake8
    future
    humanize
    mock
    pip
    polib
    polib
    prompt_toolkit
    pygments
    pylint
    pytest
    pytest
    pytest
    pytest-cov
    pytest-timeout
    python-dateutil
    requests
    setuptools
    sqlparse
    tox
    twine
    wheel
  ]);

  # Run-time dependencies
  buildInputs = [ ];

  #checkInputs = [ pythonPackages.nose ];

  patches = [ ./0001-skipToolDownloads.patch ./0002-skipToolCopies.patch ];

  configurePhase = ''
    # make the sqltoolsservice files available in a known location
    ln -s ${sqlTools.manylinux.archive} ./bin
  '';

  doCheck = true;

  buildPhase = ''
    export HOME=$TMPDIR/homeless-shelter
    mkdir -p $HOME
    patchShebangs ./mssql-cli
    python dev_setup.py
    python build.py build

    # delete the redundant "dev" wheel (it's identical to the 1.1.0 wheel)
    rm dist/mssql_cli-dev*

    # try to avoid `ERROR: mssql_cli-dev-latest-py2.py3-none-manylinux1_x86_64.whl is not a supported wheel on this platform.`
    ${pkgs.util-linux}/bin/rename 'manylinux1_x86_64' 'any' dist/*.whl

    # run tests? (how to start an instance of Sql Server?)
    # https://github.com/dbcli/mssql-cli/blob/0c3bceeebf4780e4ec6d75d926cb25b602570744/doc/development_guide.md#Run_Unit_Tests_Integration_Tests
  '';

  preCheck = ''
    export HOME=$TMPDIR
  '';

  postInstall = ''
    for p in $out/bin/*; do
      wrapProgram $p --prefix PYTHONPATH : "$PYTHONPATH" \
        --set MSSQLTOOLSSERVICE_PATH ${sqlTools.manylinux.archive}
    done
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/mssql-cli --help > /dev/null
  '';

  meta = with lib; {
    homepage = "https://github.com/dbcli/mssql-cli";
    description =
      "A command-line client for SQL Server with auto-completion and syntax highlighting";
    license = licenses.bsd3;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
