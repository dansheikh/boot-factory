function dependencies::id {
    dep_id_list=('com.squareup.retrofit2')
    dep_version_list=()

    for dep_id in ${dep_id_list[@]}; do
        dep_version_list+=$(curl -vs "http://search.maven.org/solrsearch/select?q=id:%22${dep_id}%22" 2>&1 | awk 'match($0, /\"latestVersion\":\"[0-9](\.[0-9]+)*\"/) {print substr($0, RSTART, RLENGTH)}' | grep -Eo '[0-9](\.[0-9]+)*')
    done
}
