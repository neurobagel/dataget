#!/bin/bash

dataset_f=$1
participant_f=$2
out=${3-.}
jobs=${4-6}

getit() {
    datalad get --dataset $(cut  -d " " -f1 <<< $1) $(cut -d " " -f2 <<< $1)
}
export -f getit

[ ! -e ${out} ] && mkdir -p ${out}

{
    read
    while read -r dataset;
    do

        ds_id=$(cut -f1 <<< $dataset)
        ds_url=$(cut -f3 <<< $dataset)

        echo Will now install ${ds_id} from ${ds_url}.

        (
            cd ${out}
            datalad install ${ds_url}
        )

        for ses in $(grep $ds_id ${participant_f} | cut -f8);
        do
            ds_name=$( echo $ses | cut -d "/" -f2)
            ses_path=$( echo $ses | cut -d "/" -f3-)
            echo ${out}/${ds_name} ${out}/${ds_name}/${ses_path}
        done | parallel -j${jobs} --jl ${out}/parallel.log getit ::: 2>&1 | tee ${out}/parallel.outs

    done
} < ${dataset_f}
