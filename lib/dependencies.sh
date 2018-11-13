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
    local dep_id_list=('com.squareup.retrofit2:retrofit' 'org.spockframework:spock-core')
    local dep_id_version=()
    local version=''

    echo -e "Setting up dependencies..."

    for dep_id in ${dep_id_list[@]}; do
        echo -e "Searching: http://search.maven.org/solrsearch/select?q=id:%22${dep_id}%22"

        version=$(curl -vs "http://search.maven.org/solrsearch/select?q=id:%22${dep_id}%22" 2>&1 | awk 'match($0, /\"latestVersion\":\"[0-9](\.[0-9]+)*\"/) {print substr($0, RSTART, RLENGTH)}' | grep -Eo '[0-9](\.[0-9]+)*')

        if [[ -n "${version}" ]]; then
          dep_id_version+="${version}"
        else
          dep_id_version+="0.0.0"
        fi
    done
}
