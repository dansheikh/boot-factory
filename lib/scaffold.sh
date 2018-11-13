function scaffold::core_content {
  if [[ "$#" < 2 ]]; then
    echo -e "[scaffold::core_content] Path and core file are (at minimum) required."
  fi

  local path="${1}/${2}"

  case "${2}" in
    'build.gradle')
cat <<-EOF > "${path}"
buildscript {
    ext {
        springBootVersion = '2.0.4.RELEASE'
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

sourceCompatibility = 1.8
group = '${3}'
version = "\${version}"
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

function scaffold::files {
  if [[ "$#" != 3 ]]; then
    echo -e "[scaffold::files] Path to project root, group id, and project name are required."
  fi
  
  local target="${1}"
  local group_id="${2}"
  local project="${3}"
  local core_files=('build.gradle' 'gradle.properties' 'README.md' 'settings.gradle')

  echo -e "Setting up project files..."

  for core in "${core_files[@]}"; do
    touch "${target}/${core}"
    case "${core}" in
      'build.gradle')
        scaffold::core_content "${target}" "${core}" "${group_id}"
        ;;
      'README.md')
        scaffold::core_content "${target}" "${core}" "${project}"
        ;;
      'settings.gradle')
        scaffold::core_content "${target}" "${core}" "${project}"
        ;;
      *)
        scaffold::core_content "${target}" "${core}"
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
  if [[ "$#" != 4 ]]; then
     echo -e "[scaffold::setup] Root, project, and package arguments are required."
     exit 1
  fi
     
     local root="${1}"
     local project="${2}"
     local group_id="${3}"
     local artifact_id="${4}"
     local package=$(echo -e "${group_id}/${artifact_id}" | sed 's/\./\//g')
     local target="${root%/}/${project}"

     scaffold::directories "${target}" "${package}"
     scaffold::files "${target}" "${group_id}" "${project}"
}
