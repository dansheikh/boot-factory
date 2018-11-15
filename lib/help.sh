function help::usage {
  if [[ -n $1 ]]; then
  cat <<-EOF
  Invalid option '-${1}'  

EOF
  fi

	cat <<-EOF
  Usage:

  $0 --groupId org.example --artifactId test --name main-class-name --project project-name --version 1.9 --secure --xml project-dir

      Parameters             Description
      ----------             -----------
      -a, --artifactId       Artifact Id.
      -g, --groupId          Group Id.
      -h, --help             Utility help documentation.
      -n, --name             Main class name.
      -p, --project          Project name.
      -s, --secure           [Optional flag] Enable security.
      -v, --version          [Optional] Java version, defaults to 1.8
      -x, --xml              [Optional flag] Enable SOAP client support.

	EOF
}
