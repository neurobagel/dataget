#!/bin/bash

machine_f=$1
out=${2-.}
jobs=${3-6}

getit() {
    datalad get --dataset $(cut  -d " " -f1 <<< $1) $(cut -d " " -f2 <<< $1)
}
export -f getit

[ ! -e ${out} ] && mkdir -p ${out}

{
    # Skip the header row of the machine_f file
    read
    while read -r dataset || [ -n "$dataset" ]; do

        ds_full_name=$(cut -f1 <<< $dataset)
        ds_url=$(cut -f2 <<< $dataset)
        ses=$(cut -f5 <<< $dataset)

        echo Will now install "'"${ds_full_name}"'" from ${ds_url}.

        (
            cd ${out}
            datalad install ${ds_url}
        )

        for ses_path in $ses; do
            ds_name=$(echo $ses_path | cut -d "/" -f2)
            ses_subpath=$(echo $ses_path | cut -d "/" -f3-)
            echo ${out}/${ds_name} ${out}/${ds_name}/${ses_subpath}
        done | parallel -j${jobs} --jl ${out}/parallel.log getit ::: 2>&1 | tee ${out}/parallel.outs

    done
} < ${machine_f}
