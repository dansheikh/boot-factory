# Load templates.
. "${BASH_SOURCE%/*}/templates.sh" 

function scaffold::resource_files {
  if [[ "$#" != 3 ]]; then
    echo -e "[scaffold::build_files] Path to project root, group id, and artifact id are required."
  fi
  
  local target="${1}"
  local group_id="${2}"
  local artifact_id="${3}"
  local file_paths=('src/main/resources/application.yml' 'src/main/resources/log4j2.yml')
  local file_name=''

  for file_path in "${file_paths[@]}"; do
    touch "${target}/${file_path}"
    file_name="${file_path##*/}"
    case "${file_name}" in
      'application.yml')
        templates::app_yaml "${target}" "${file_path}"
        ;;
      'log4j2.yml')
        templates::log4j2_yaml "${target}" "${file_path}"
        ;;
    esac
  done

}

function scaffold::build_content {
  if [[ "$#" < 2 ]]; then
    echo -e "[scaffold::build_content] Path and core file are (at minimum) required."
  fi

  local path="${1}/${2}"

  case "${2}" in
    'build.gradle')
cat <<-EOF > "${path}"
buildscript {
    ext {
        springBootVersion = '${dep_id_version[0]}'
    }
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath("org.springframework.boot:spring-boot-gradle-plugin:\${springBootVersion}"
    }
}

apply plugin: 'java'
apply plugin: 'application'
apply plugin: 'org.springframework.boot'
apply plugin: 'io.spring.dependency-management'
apply plugin: 'eclipse'
apply plugin: 'idea'

sourceCompatibility = ${4}
group = '${3}'
version = "\${version}"
$(templates::build_tasks)
EOF
      ;;
    'gradle.properties')
cat <<-EOF > "${path}"
# JVM and project specific properties.
version = 0.0.1
EOF
      ;;
    'README.md')
cat <<-EOF > "${path}"
# ${3}
EOF
      ;;
    'settings.gradle')
cat <<-EOF > "${path}"
rootProject.name = '${3}' 
EOF
      ;;
  esac
}

function scaffold::build_files {
  if [[ "$#" != 4 ]]; then
    echo -e "[scaffold::build_files] Path to project root, group id, project name, and java version are required."
  fi
  
  local target="${1}"
  local group_id="${2}"
  local project="${3}"
  local java_version="${4}"
  local file_paths=('build.gradle' 'gradle.properties' 'README.md' 'settings.gradle')

  echo -e "Setting up project files..."

  for file_path in "${file_paths[@]}"; do
    touch "${target}/${file_path}"
    case "${file_path}" in
      'build.gradle')
        scaffold::build_content "${target}" "${file_path}" "${group_id}" "${java_version}"
        ;;
      'README.md')
        scaffold::build_content "${target}" "${file_path}" "${project}"
        ;;
      'settings.gradle')
        scaffold::build_content "${target}" "${file_path}" "${project}"
        ;;
      *)
        scaffold::build_content "${target}" "${file_path}"
        ;;
      esac
  done
}

function scaffold::directories {
  local target="${1}"
  local package="${2}"
  local core_dirs=('configuration' 'domain' 'logic' 'presentation')
  local domain_dirs=('entities' 'repositories')
  local logic_dirs=('services')
  local presentation_dirs=('controllers' 'bindings/requests' 'bindings/responses')

  if [[ -d "${target}" ]]; then
    echo -e "[scaffold::directories] Path to project root [${target}] is occupied."
    exit 1
  fi

  # Setup directory structure. 
  echo -e "Setting up project directories..."
  mkdir -p "${target}" "${target}/src/main/java/${package}" "${target}/src/main/resources" "${target}/src/test/groovy" "${target}/src/test/java"

  # Setup core directories.
  for dir in "${core_dirs[@]}"; do
    mkdir -p "${target}/src/main/java/${package}/${dir}"
  done

  # Setup domain directories.
  for domain in "${domain_dirs[@]}"; do
    mkdir -p "${target}/src/main/java/${package}/domain/${domain}"
  done

  # Setup logic directories.
  for logic in "${logic_dirs[@]}"; do
    mkdir -p "${target}/src/main/java/${package}/logic/${logic}"
  done

  # Setup presentation directories.
  for presentation in "${presentation_dirs[@]}"; do
    mkdir -p "${target}/src/main/java/${package}/presentation/${presentation}"
  done
}

function scaffold::setup {
  if [[ "$#" != 5 ]]; then
     echo -e "[scaffold::setup] Root, project, package, and java version arguments are required."
     exit 1
  fi
     
     local root="${1}"
     local project="${2}"
     local group_id="${3}"
     local artifact_id="${4}"
     local java_version="${5}"
     local package=$(echo -e "${group_id}/${artifact_id}" | sed 's/\./\//g')
     local target="${root%/}/${project}"

     scaffold::directories "${target}" "${package}"
     scaffold::build_files "${target}" "${group_id}" "${project}" "${java_version}"
     scaffold::resource_files "${target}" "${group_id}" "${artifact_id}"
}
