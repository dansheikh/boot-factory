function help::usage {
  if [[ -n $1 ]]; then
  cat <<-EOF
  Invalid option '-${1}'  

EOF
  fi

	cat <<-EOF
  Usage:

  $0 --groupId org.example --artifactId test --name main-class-name --project project-name --secure project-dir

      Parameters             Description
      ----------             -----------
      -a, --artifactId       Artifact Id.
      -g, --groupId          Group Id.
      -h, --help             Utility help documentation.
      -n, --name             Main class name.
      -p, --project          Project name.
      -s, --secure           [Optional] Enable security.

	EOF
}
