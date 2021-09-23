{ lib, pythonPackages, source }:
let
  pname = "mssql-scripter";
  version = "1.0.0";
in
pythonPackages.buildPythonApplication {
  inherit pname version;

  src = source;
  #pythonPackages.fetchPypi {
  #  inherit pname version;
  #  sha256 = "0gs791yb0cndg9879vayvcj329jwhzpk6wrf9ri12l5hg8g490za";
  #};

  propagatedBuildInputs = (with pythonPackages; [ click pygments ]);

  checkInputs = [ pythonPackages.nose ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  postInstall = ''
    #rm -r $out/${pythonPackages.python.sitePackages}/PyGitUp/tests
  '';

  meta = with lib; {
    homepage = "https://github.com/dbcli/mssql-cli";
    description = "A command-line client for SQL Server with auto-completion and syntax highlighting";
    license = licenses.bsd3;
    maintainers = [];
    platforms = platforms.all;
  };
}
