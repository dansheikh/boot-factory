# Runtime dependencies.
runtime_ids=('org.springframework.boot:spring-boot-devtools')
runtime_id_versions=()

# Compile-time dependencies.
compile_ids=('org.springframework.boot:spring-boot-gradle-plugin' 'com.squareup.retrofit2:retrofit' 'org.spockframework:spock-core')
compile_id_versions=()

# Test compile-time dependencies.
test_compile_ids=('org.springframework.boot:spring-boot-starter-test' 'org.springframework.security:spring-security-test')
test_compile_id_versions=()

# JAX-WS dependencies.
jaxws_ids=('com.sun.xml.ws:jaxws-tools')
jaxws_id_versions=()

function dependencies::camelCase {
  local artifact="${1}"
  local cased_string=$(echo "${1}" | awk '{
       count = 0;
       while (match($0, /[a-z]+/)) {
             find = substr($0, RSTART, RLENGTH);
             if (count > 0) {
                printf "%s", toupper(substr(find, 1, 1));
                printf "%s", substr(find, 2);
             } else {
                printf "%s", find;
             }
             count++;
             $0 = substr($0, RSTART + RLENGTH);      
       }
  }')

  echo "${cased_string}"
}

function dependencies::extractArtifact {
  local id="${1}"
  echo "${id#*:}"
}

function dependencies::id {
  local args=("$@")
  local size=$#
  local limit=$(($size - 1))
  local dep_ids=("${args[@]:0:$limit}")
  local type="${args[@]:$limit}"
  local version_ids=()
  local version=''

  for dep_id in "${dep_ids[@]}"; do
    # echo -e "Searching: http://search.maven.org/solrsearch/select?q=id:%22${dep_id}%22"

    version=$(curl -vs "http://search.maven.org/solrsearch/select?q=id:%22${dep_id}%22" 2>&1 | awk 'match($0, /\"latestVersion\":\"[0-9]([\.-]+[0-9A-Za-z]+)*\"/) {print substr($0, RSTART, RLENGTH)}' | grep -Eo '[0-9]([\.-]+[0-9A-Za-z]+)*')

    if [[ -z "${version}" ]]; then
      version="0.0.0"
    fi

    version_ids+=("${version}")

  done
  
  case "${type}" in
    "runtime")
      echo "${version_ids[@]}" > /tmp/boot-factory-run-time.txt
    ;;
    "compile")
      echo "${version_ids[@]}" > /tmp/boot-factory-compile-time.txt
    ;;
    "test-compile")
      echo "${version_ids[@]}" > /tmp/boot-factory-test-compile-time.txt
    ;;
    "jaxws")
      echo "${version_ids[@]}" > /tmp/boot-factory-jax-ws-time.txt
    ;;
    esac
}

function dependencies::main {
  local pids=()
  local total=4
  local complete=0
  local tmp=0
  local hashes='#####'

  dependencies::id "${runtime_ids[@]}" "runtime" &
  pids+=($!)
  dependencies::id "${compile_ids[@]}" "compile" &
  pids+=($!)
  dependencies::id "${test_compile_ids[@]}" "test-compile" &
  pids+=($!)

  if [[ $secure == 0 ]]; then
    dependencies::id "${jaxws_ids[@]}" "jaxws" &
    pids+=($!)
  fi

  echo -n "Configuring dependencies..."
  
  while sleep 1; do
    echo -n "."
  done &

  wait "${pids[@]}"

  kill $! && wait $! 2>/dev/null

  # Clear dependencies configuration indicator line.
  echo ""

  # Slurp variables from temporary files.
  runtime_id_versions+=($(</tmp/boot-factory-run-time.txt))
  compile_id_versions+=($(</tmp/boot-factory-compile-time.txt))
  test_compile_id_versions+=($(</tmp/boot-factory-test-compile-time.txt))
  jaxws_id_versions+=($(</tmp/boot-factory-jax-ws-time.txt))

  # Clean-up temporary files.
  rm -f /tmp/boot-factory-*-time.txt 
}
