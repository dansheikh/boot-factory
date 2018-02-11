#!/usr/bin/env bash

# Configure command-line arguments.
OPTS=`getopt -o a:b:d:g:hl:n: -l artifactId:,build:,dependencies:,groupId:,help,language:name: -n 'unitedshoe' -- "$@"`

unitedshoe_help() {
  echo -e "Usage:\n\t$0 --groupId org.example --artifactId test --dependencies web,jpa --build gradle --language kotlin path-to-project\n\nNote: 'build' and 'language' are optional."
  exit 0
}

if [ $? != 0 ]; then
    echo 'Unable to parse options.' 2>&1
    exit 1
fi

if [ $# -eq 0 ]; then
    unitedshoe_help
fi

eval set -- "$OPTS"

# Verify installation of Sdkman.
if [ -s $HOME/.sdkman/bin/sdkman-init.sh ]; then
    source $HOME/.sdkman/bin/sdkman-init.sh 
    # Verify installation of Spring Boot CLI.
    springboot=$(command -v spring 2> /dev/null)

    if [ -z $springboot ]; then
	      cat <<EOF
Please install Sprint Boot CLI.
See installation instructions:
https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started-installing-spring-boot.html#getting-started-sdkman-cli-installation
EOF
	      exit 1
    fi
else
  cat <<EOF
Please install Sdkman and Sprint Boot CLI.
See respective installation instructions:
http://sdkman.io/install.html
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
	  -h | --help) unitedshoe_help;;
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
    err_msgs+="Excessive arguments provided; see help."
fi

if [ $# -lt 1 ]; then
    err_msgs+="Path to project is required; see help."
fi

if [ ${#err_msgs[@]} -gt 0 ]; then
    echo -e "${err_msgs[@]}"
    exit 1
fi

# Execute Spring Boot CLI.
eval "spring init --groupId $groupId --artifactId $artifactId --build $build --dependencies $dependencies --language $language --name $name $@"

# Setup directories.
base_path=$(echo "$groupId/$artifactId" | sed 's/\./\//g')
src_path="src/main/java"
dirs=('api/bindings' 'api/contracts' 'api/controllers' 'configurations' 'entities' 'repositories' 'services')

((dir_cnt=${#dirs[@]}-1))
echo -e "Setting up directories."
for idx in $(seq 0 $dir_cnt); do
  mkdir -p "$1/$src_path/$base_path/${dirs[idx]}"
done

# Inject templates.
base_pkg="$groupId.$artifactId"
factory_dir=$(dirname $0)
templates_dir="$factory_dir/templates"

# Iterate over all template files.
echo -e "Adding templates."
for file in "$templates_dir/"*; do
  if [ -f $file ]; then
      file_basename=$(basename $file)
      file_path=$(echo $file_basename | rev | sed -u 's/\./\//2g' | tee | rev)
      pkg="${file_basename%.*}"
      
      cp "$file" "$1/$src_path/$base_path/$file_path"
      sed -E -i'' '1s/^/'"package $base_pkg.$pkg;"'\n\n/' "$1/$src_path/$base_path/$file_path"
  fi
done
