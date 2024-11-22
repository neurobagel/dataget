#!/bin/bash
# Example usage:
# ./entrypoint.sh <machine_f> [<output_dir>] [<number_of_jobs>]

# The <machine_f> is the path to the cohort-participant-machine-results.tsv file downloaded from the neurobagel query tool.

# The <output_dir> is an optional argument that specifies where the datasets should be installed.
# If not provided, the current directory will be used.

# The <number_of_jobs> is an optional argument that specifies the number of parallel jobs to run.
# If not provided, the default value of 6 will be used.

machine_f=$1
output_dir=${2-.}
jobs=${3-6}

getdata() {
    dataset=$(cut -d " " -f1 <<< "$1")
    content=$(cut -d " " -f2 <<< "$1")
    datalad get --dataset "$dataset" "$content"
}
export -f getdata

[ ! -e ${output_dir} ] && mkdir -p ${output_dir}

# dataset installations
tail -n +2 "$machine_f" | cut -f1,2 | sort | uniq | parallel -j"${jobs}" --joblog "${output_dir}/parallel.log" "
  ds_full_name=\$(cut -f1 <<< {})
  ds_url=\$(cut -f2 <<< {})
  # NOTE: ds_full_name and ds_url references must be unbraced to ensure they aren't expanded in the parent shell
  echo \"Will now install '\$ds_full_name' from '\$ds_url'.\"
  (
    cd \"${output_dir}\" || exit
    datalad install \"\$ds_url\"
  )
" ::: 2>&1 | tee -a "${output_dir}/parallel.outs"

# session processing
{
    # Skip the header row of the machine_f file
    read
    # Ensure last line is read even if file does not end with newline
    # See: https://stackoverflow.com/a/12916758
    while read -r dataset || [ -n "$dataset" ]; do

        ses_path=$(cut -f5 <<< "$dataset")

        if [ -n "$ses_path" ]; then
            ds_name=$(echo "$ses_path" | cut -d "/" -f2)
            ses_subpath=$(echo "$ses_path" | cut -d "/" -f3-)
            echo "${output_dir}/${ds_name} ${output_dir}/${ds_name}/${ses_subpath}"
        fi

    done | parallel -j"${jobs}" --joblog "${output_dir}/parallel.log" "getdata {}" ::: 2>&1 | tee "${output_dir}/parallel.outs"
} < "$machine_f"
