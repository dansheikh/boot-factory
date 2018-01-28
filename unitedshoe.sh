#!/usr/bin/env bash

# Configure command-line arguments.
OPTS=`getopt -o a:b:d:g:hl:n: -l artifactId:,build:,dependencies:,groupId:,help,language:name: -n 'unitedshoe' -- "$@"`

if [ $? != 0 ]; then
  echo 'Unable to parse options.' 2>&1
  exit 1
fi

if [ $# -eq 0 ]; then
  echo -e "Usage:\n\t$0 --groupId org.example --artifactId test --dependencies web,jpa --build gradle --language kotlin path-to-project\n\nNote: 'build' and 'language' are optional."
  exit 0;
fi

eval set -- "$OPTS"

# Verify installation of Sdkman.
if [ -z command -v sdk &> /dev/null ]; then

cat <<EOF
Please install Sdkman and Sprint Boot CLI.
See respective installation instructions:
http://sdkman.io/install.html
https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started-installing-spring-boot.html#getting-started-sdkman-cli-installation
EOF

exit 1

fi

# Verify installation of Spring Boot CLI.
if [ -z command -v spring &> /dev/null ]; then

cat <<EOF
Please install Sprint Boot CLI.
See installation instructions:
https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started-installing-spring-boot.html#getting-started-sdkman-cli-installation
EOF

exit 1

fi

# Establish defaults.
build="gradle"
language="java"

while true; do
  case "$1" in
    -a | --artifactId) artifactId="$2"; shift 2;;
    -b | --build) build="$2"; shift 2;;
    -d | --dependencies) dependencies="$2"; shift 2;;
    -g | --groupId) groupId="$2"; shift 2;;
    -h | --help) echo -e "Usage:\n\t$0 --groupId org.example --artifactId test --dependencies web,jpa --build gradle --language kotlin path-to-project\n\nNote: 'build' and 'language' are optional."; exit 0;;
    -l | --language) language="$2"; shift 2;;
    -n | --name) name="$2"; shift 2;;
    --) shift; break;;
    *) break;;
  esac
done

# Check for usage errors.
err_msgs=()

if [ -z $groupId ]; then
  err_msgs+="Group Id is required. "
fi

if [ -z $artifactId ]; then
  err_msgs+="Artifact Id is required. "
fi

if [ -z $dependencies ]; then
  err_msgs+="Dependencies are required."
fi

if [ -z $name ]; then
  err_msgs+="Application name is required."
fi

if [ $# -gt 1 ]; then
  err_msgs+="Excessive arguments provided. See help."
fi

if [ $# -lt 1 ]; then
  err_msgs+="Path to project is required. See help."
fi

if [ ${#err_msgs[@]} -gt 0 ]; then
  echo ${err_msgs[@]}
  exit 1;
fi

# Execute Spring Boot CLI.
eval "spring init --groupId $groupId --artifactId $artifactId --build $build --dependencies $dependencies --language $language --name $name $@"
