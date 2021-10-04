#!/bin/bash
set -exuo pipefail
OC='oc -n {{ osbs_ocp_namespace }}'

delete_threshold=$(date --date="{{ osbs_pruner_pods_days_old }} days ago" --iso-8601=seconds
--utc)

old_pods=$(
    $OC get pods -o json | \
    jq '.items[].metadata | select(.creationTimestamp < "'${delete_threshold}'") | .name' -r | \
    sort -u
)

if [ -z "$old_pods" ]
then
    echo "Nothing to remove."
    exit 0
fi

echo -e "${old_pods}"
echo
count=$(wc -l <<<${old_pods})

echo "SUMMARY: ${count} Pods will be removed"
echo ${old_pods} | xargs -n 10 $OC delete pod
