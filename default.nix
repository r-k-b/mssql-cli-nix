{ lib, pkgs, pythonPackages, source, stdenv, tree }:
let
  pname = "mssql-scripter";
  version = "1.0.0";

  sqltoolsservice-release = "v3.0.0-release.72";

  archiveFrom = { folder, file, sha256 }: {
    archive = builtins.fetchurl {
      url = "https://github.com/microsoft/sqltoolsservice/releases/download/"
        + "${sqltoolsservice-release}/${file}";
      inherit sha256;
    };
    name = file;
    inherit folder;
  };

  sqlTools = {
    manylinux = archiveFrom {
      folder = "manylinux1";
      file = "Microsoft.SqlTools.ServiceLayer-rhel-x64-netcoreapp3.1.tar.gz";
      sha256 = "sha256:1ph63sjv7h3h94dc7by4v9hshag8s30fyibz92pq8f93zq1ys8kb";
    };
    macosx = archiveFrom {
      folder = "macosx_10_11_intel";
      file = "Microsoft.SqlTools.ServiceLayer-osx-x64-netcoreapp3.1.tar.gz";
      sha256 = "sha256:170fq2ypbpmwb2h9bd6l4ic250qdcpf368zvjf2962czbxqb2hwa";
    };
    win64 = archiveFrom {
      folder = "win_amd64";
      file = "Microsoft.SqlTools.ServiceLayer-win-x64-netcoreapp3.1.zip";
      sha256 = "sha256:0xjkd491pdln75la5bclga5waiqjiaiy4pnmr52jjfvwrh1jznhy";
    };
    win32 = archiveFrom {
      folder = "win32";
      file = "Microsoft.SqlTools.ServiceLayer-win-x86-netcoreapp3.1.zip";
      sha256 = "sha256:10r6xb1n0aqx5fr78bcj0h88x2g9w0haa77anbdmgiiqk8yqlnv9";
    };
  };

  skipToolDownloads = pkgs.writeText "skipToolDownloads.patch" ''
    Index: mssqlcli/mssqltoolsservice/externals.py
    IDEA additional info:
    Subsystem: com.intellij.openapi.diff.impl.patch.CharsetEP
    <+>UTF-8
    ===================================================================
    diff --git a/mssqlcli/mssqltoolsservice/externals.py b/mssqlcli/mssqltoolsservice/externals.py
    --- a/mssqlcli/mssqltoolsservice/externals.py	(revision 6509aa2fc226dde8ce6bab7af9cbb5f03717b936)
    +++ b/mssqlcli/mssqltoolsservice/externals.py	(date 1632528436596)
    @@ -1,6 +1,7 @@
     from __future__ import print_function

     import os
    +import errno
     import sys
     import tarfile
     import zipfile
    @@ -33,15 +34,8 @@
             Download each for the plaform specific sqltoolsservice packages
         """
         for packageFilePath in SUPPORTED_PLATFORMS.values():
    -        if not os.path.exists(os.path.dirname(packageFilePath)):
    -            os.makedirs(os.path.dirname(packageFilePath))
    -
    -        packageFileName = os.path.basename(packageFilePath)
    -        githubUrl = 'https://github.com/microsoft/sqltoolsservice/releases/download/{}/{}'.format(SQLTOOLSSERVICE_RELEASE, packageFileName)
    -        print('Downloading {}'.format(githubUrl))
    -        r = requests.get(githubUrl)
    -        with open(packageFilePath, 'wb') as f:
    -            f.write(r.content)
    +        if not os.path.exists(packageFilePath):
    +            raise FileNotFoundError(errno.ENOENT, 'You need to supply these files', packageFilePath)

     def copy_sqltoolsservice(platform):
         """
  '';

  #pythonPackages.buildPythonApplication {
in stdenv.mkDerivation {
  inherit pname version;

  src = source;
  #pythonPackages.fetchPypi {
  #  inherit pname version;
  #  sha256 = "0gs791yb0cndg9879vayvcj329jwhzpk6wrf9ri12l5hg8g490za";
  #};

  # Compile-time dependencies
  nativeBuildInputs = (with pkgs; [ git ]) ++ (with pythonPackages; [
    applicationinsights
    azure-core
    #bumpversion # do we need to package this ourselves? how?
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

  patchPhase = ''
    git apply ${skipToolDownloads}
  '';

  configurePhase = ''
    # "add" the sqltoolsservice files
    mkdir -p sqltoolsservice/${sqlTools.manylinux.folder}
    ln -s ${sqlTools.manylinux.archive} sqltoolsservice/${sqlTools.manylinux.folder}/${sqlTools.manylinux.name}
    mkdir -p sqltoolsservice/${sqlTools.macosx.folder}
    ln -s ${sqlTools.macosx.archive} sqltoolsservice/${sqlTools.macosx.folder}/${sqlTools.macosx.name}
    mkdir -p sqltoolsservice/${sqlTools.win64.folder}
    ln -s ${sqlTools.win64.archive} sqltoolsservice/${sqlTools.win64.folder}/${sqlTools.win64.name}
    mkdir -p sqltoolsservice/${sqlTools.win32.folder}
    ln -s ${sqlTools.win32.archive} sqltoolsservice/${sqlTools.win32.folder}/${sqlTools.win32.name}
  '';

  buildPhase = ''
    python dev_setup.py
    python build.py build

    # run tests? (how to start an instance of Sql Server?)
    # https://github.com/dbcli/mssql-cli/blob/0c3bceeebf4780e4ec6d75d926cb25b602570744/doc/development_guide.md#Run_Unit_Tests_Integration_Tests
  '';

  installPhase = ''
    mkdir -p $out
    cp -r dist $out # this is only a .whl file?
  '';

  preCheck = ''
    export HOME=$TMPDIR
  '';

  postInstall = ''
    #rm -r $out/${pythonPackages.python.sitePackages}/PyGitUp/tests
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
