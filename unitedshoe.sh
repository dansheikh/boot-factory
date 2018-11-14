#!/usr/bin/env bash

# Load helper scripts.
. "${BASH_SOURCE%/*}/lib/dependencies.sh"
. "${BASH_SOURCE%/*}/lib/help.sh"
. "${BASH_SOURCE%/*}/lib/scaffold.sh"

function main {
  local undefined='Undefined'
  local group_id=''
  local artifact_id=''
  local main_name=''
  local project=''
  local secure=false
  local path=''

  local machine=$(uname -s)
  local optspec=":ahgnps-:"

  while getopts "${optspec}" opt $@; do
    case "${opt}" in
      a)
        artifact_id="${!OPTIND}"; OPTIND=$((OPTIND + 1))
        ;;
      h)
        help::usage
        exit 0
        ;;
      g)
        group_id="${!OPTIND}"; OPTIND=$((OPTIND + 1))
        ;;
      n)
        main_name="${!OPTIND}"; OPTIND=$((OPTIND + 1))
        ;;
      p)
        project="${!OPTIND}"; OPTIND=$((OPTIND + 1))
        ;;
      s)
        secure=true
        ;;
      -)
        case "${OPTARG}" in
          help)
            help::usage
            exit 0
            ;;
          groupId)
            group_id="${!OPTIND}"; OPTIND=$((OPTIND + 1))
            ;;
          groupId=*)
            group_id="${OPTARG#*=}"; 
            ;;
          artifactId)
            artifact_id="${!OPTIND}"; OPTIND=$((OPTIND + 1))
            ;;
          artifactId=*)
            artifact_id="${OPTARG#*=}"
            ;;
          name)
            main_name="${!OPTIND}"; OPTIND=$((OPTIND + 1))
            ;;
          name=*)
            main_name="${OPTARG#*=}"
            ;;
          project)
            project="${!OPTIND}"; OPTIND=$((OPTIND + 1))
            ;;
          project=*)
            project="${OPTARG#*}"
            ;;
          *)
            if [[ "$OPTERR" = 1 && "${optspec:0:1}" != ":" ]]; then
              echo "Unknown argument --${OPTARG}" >&2
            fi
        esac
        ;;
      \?)
        help::usage "${OPTARG}"
        exit 1
        ;;
    esac
  done

  # Shift to allow for post option processing.
  shift $((OPTIND - 1))

  if [[ $# == 1 ]]; then
    path=$1
  fi

  if [[ -z "$group_id" || -z "$artifact_id" || -z "$main_name" || -z "$project" || -z "$path" ]]; then
    echo "Error: 'groupId' [${group_id:-undefined}], 'artifactId' [${artifact_id:-undefined}], 'name' [${main_name:-undefined}], 'project' [${project:-undefined}], and 'path' [${path:-undefined}] are required!"
  fi

  # 1. Version dependencies.
  dependencies::id
  # 2. Create scaffold, i.e. directories and files.
  scaffold::setup "${path}" "${project}" "${group_id}" "${artifact_id}"
}

main "$@"

## Configure command-line arguments.
#OPTS=''
#
#case "${machine}" in
#  Linux*) OPTS=`getopt -o a:b:d:g:hl:m: -l artifactId:,build:,dependencies:,groupId:,help,language:main: -n 'unitedshoe' -- "$@"`;;
#  Darwin*) OPTS=`getopt a:b:d:g:hl:m: -- "$*"`;;
#esac
#
#
#if [ $? != 0 ]; then
#    echo 'Unable to parse options.' 2>&1
#    exit 1
#fi
#
#if [ $# -eq 0 ]; then
#    unitedshoe_help
#fi
#
#eval set -- "$OPTS"
#
## Verify installation of Sdkman.
#if [ -s $HOME/.sdkman/bin/sdkman-init.sh ]; then
#    source $HOME/.sdkman/bin/sdkman-init.sh
#    # Verify installation of Spring Boot CLI.
#    springboot=$(command -v spring 2> /dev/null)
#
#    if [ -z $springboot ]; then
#  cat <<-EOF
#	Please install Sprint Boot CLI.
#	See installation instructions:
#	https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started-installing-spring-boot.html#getting-started-sdkman-cli-installation
#	EOF
#	      exit 1
#    fi
#else
#	cat <<-EOF
#	Please install Sdkman and Sprint Boot CLI.
#	See respective installation instructions:
#	http://sdkman.io/install.html
#	https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started-installing-spring-boot.html#getting-started-sdkman-cli-installation
#	EOF
#  exit 1
#fi
#
## Establish defaults.
#build="gradle"
#language="java"
#
#while true; do
#  case "$1" in
#	  -a | --artifactId) artifactId="$2"; shift 2;;
#	  -b | --build) build="$2"; shift 2;;
#	  -d | --dependencies) dependencies="$2"; shift 2;;
#	  -g | --groupId) groupId="$2"; shift 2;;
#	  -h | --help) unitedshoe_help;;
#	  -l | --language) language="$2"; shift 2;;
#	  -m | --main) main="$2"; shift 2;;
#	  --) shift;;
#	  *) break;;
#  esac
#done
#
## Check for usage errors.
#err_msgs=()
#
#if [ -z $groupId ]; then
#    err_msgs+="Group Id is required. "
#fi
#
#if [ -z $artifactId ]; then
#    err_msgs+="Artifact Id is required. "
#fi
#
#if [ -z $dependencies ]; then
#    err_msgs+="Dependencies are required."
#fi
#
#if [ -z $main ]; then
#    err_msgs+="Main class name is required."
#fi
#
#if [ $# -gt 1 ]; then
#    err_msgs+="Excessive arguments provided; see help."
#fi
#
#if [ $# -lt 1 ]; then
#    err_msgs+="Path to project is required; see help."
#fi
#
#if [ ${#err_msgs[@]} -gt 0 ]; then
#    echo -e "${err_msgs[@]}"
#    exit 1
#fi
#
## Execute Spring Boot CLI.
#eval "spring init --groupId $groupId --artifactId $artifactId --build $build --dependencies $dependencies --language $language --name $main $@"
#
## Setup directories.
#base_path=$(echo "$groupId/$artifactId" | sed 's/\./\//g')
#src_path="src/main/java"
#res_path="src/main/resources"
#dirs=('api/bindings' 'api/contracts' 'api/controllers' 'configurations' 'entities' 'repositories' 'services')
#
#((dir_cnt=${#dirs[@]}-1))
#echo -e "Setting up directories."
#for idx in $(seq 0 $dir_cnt); do
#  mkdir -p "$1/$src_path/$base_path/${dirs[idx]}"
#done
#
## Inject templates.
#base_pkg="$groupId.$artifactId"
#factory_dir=$(dirname $0)
#templates_dir="$factory_dir/templates"
#
## Iterate over all template files.
#echo -e "Adding templates."
#for file in "$templates_dir/"*; do
#  if [ -f $file ]; then
#      file_basename=$(basename $file)
#      file_path=$(echo $file_basename | rev | sed 's/\./\//g' | tee | sed 's/\//\./' | tee | rev)
#      pkg_filename="${file_basename%.*}"
#      pkg="${pkg_filename%.*}"
#
#      cp "$file" "$1/$src_path/$base_path/$file_path"
#      sed -E -i.bak '1s/^/'"package $base_pkg.$pkg;"'\
  #\
  #/' "$1/$src_path/$base_path/$file_path"
#      rm "$1/$src_path/$base_path/$file_path.bak"
#  fi
#done
#
## Inject resources.
#resources_dir="$factory_dir/resources"
#
#for file in "$resources_dir"/*; do
#  cp $file "$1/$res_path/"
#done
#
## Enhance build file.
#build_filepath="$1/build.gradle"
#mv "$build_filepath" "$build_filepath~"
#touch "$build_filepath"
#
#add_ext() {
#	cat <<-EOF >> "$build_filepath"
#
#ext {
#      groovyVersion = '2.4.13'
#      retrofitVersion = '2.3.0'
#      springfoxVersion = '2.8.0'
#}
#	EOF
#}
#
#add_deps() {
#	cat <<-EOF >> "$build_filepath"
#        // Beginning of custom dependencies.
#        compile("com.squareup.retrofit2:retrofit:\${retrofitVersion}")
#        compile("com.squareup.retrofit2:converter-jackson:\${retrofitVersion}")
#        compile("io.springfox:springfox-swagger2:\${springfoxVersion}")
#        compile("io.springfox:springfox-swagger-ui:\${springfoxVersion}")
#        compile("org.codehaus.groovy:groovy:${groovyVersion}")
#        compile('org.springframework.boot:spring-boot-starter-jetty')
#        testCompile('org.spockframework:spock-spring')
#        // End of custom dependencies.
#	EOF
#}
#
#exclude_tomcat() {
#	cat <<-EOF >> "$build_filepath"
#    $1 { exclude group: 'org.springframework.boot', module: 'spring-boot-starter-tomcat' }
#	EOF
#}
#
#add_custom_tasks() {
#	cat <<-EOF >> "$build_filepath"
#
#	javadoc {
#    source sourceSets.main.allJava
#
#    title = 'Micro-Service Template Documentation'
#    options.linkSource = true
#    options.links = ['https://docs.oracle.com/javase/8/docs/api/', 'https://docs.spring.io/spring-boot/docs/current/api/']
#    options.footer = "Generated on \${new Date().format('dd MMM yyyy')}"
#    options.header = "Documentation for version \${project.version}"
#
#    failOnError false
#	}
#
#	task bootRunDev(type: org.springframework.boot.gradle.run.BootRunTask) {
#    group 'Application'
#    description 'Runs the project with development profile.'
#
#    doFirst() {
#        main = project.mainClassName
#        classpath = sourceSets.main.runtimeClasspath
#        args = ['--spring.profiles.active=dev']
#        jvmArgs = ['-Xdebug', '-Xrunjdwp:server=y,transport=dt_socket,address=5005,suspend=n']
#    }
#	}
#
#	task bootRunTest(type: org.springframework.boot.gradle.run.BootRunTask) {
#    group 'Application'
#    description 'Runs the project with test profile.'
#
#    doFirst() {
#        main = project.mainClassName
#        classpath = sourceSets.main.runtimeClasspath
#        args = ['--spring.profiles.active=test']
#    }
#	}
#
#	task bootRunPro(type: org.springframework.boot.gradle.run.BootRunTask) {
#    group 'Application'
#    description 'Runs the project with production profile.'
#
#    doFirst() {
#        main = project.mainClassName
#        classpath = sourceSets.main.runtimeClasspath
#        args = ['--spring.profiles.active=pro']
#    }
#	}
#
#	bootRun {
#    args = ["--spring.profiles.active=pro"]
#	}
#	EOF
#}
#
#add_custom_config() {
#  cased_name=$(echo $name | perl -pe 's/^(.)/\u$1/')
#  main_class="${groupId}.${artifactId}.${cased_name}Application"
#
#	cat <<-EOF >> "$build_filepath"
#
#	test {
#    systemProperty 'spring.profiles.active', 'test'
#	}
#
#	bootRepackage {
#    mainClass = '$main_class'
#	}
#	EOF
#}
#
#repos=""
#deps=""
#while IFS= read -r line || [[ -n $line ]]; do
#  if [[ "$line" =~ ^\s*repositories ]]; then
#    repos="begin"
#    echo "$line" >> "$build_filepath"
#  elif [[ "$repos" == "begin" ]] && [[ "$line" =~ } ]]; then
#    echo "$line" >> "$build_filepath"
#    add_ext
#    repos="end"
#  elif [[ "$line" =~ ^\s*dependencies ]]; then
#    echo "$line" >> "$build_filepath"
#    add_deps
#    deps="begin"
#  elif [[ "$line" =~ spring-boot-starter-web ]]; then
#    exclude_tomcat "$line"
#  elif [[ "$deps" == "begin" ]] && [[ "$line" =~ } ]]; then
#    echo "$line" >> "$build_filepath"
#    deps="end"
#    add_custom_tasks
#    add_custom_config
#  else
#    echo "$line" >> "$build_filepath"
#  fi
#done < "$build_filepath~"
#
#rm "$build_filepath~"
#
#echo "Project setup complete."
