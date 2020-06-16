#!/bin/bash

get_k8s_secret() {

k8s_namespace=$1

query_name=$2

echo "query:"

echo " namespace: $k8s_namespace"

echo " query_name: $query_name"

secret_token_name_output=$(kubectl -n "$k8s_namespace" get secret | grep "$query_name" | awk '{print $1}')

if [[ -z "$secret_token_name_output" ]]; then

echo "message: Token name not found"

else

secret_token_name=(${secret_token_name_output//"\n"/ })

if [[ "${#secret_token_name[@]}" -gt 1 ]]; then

echo "message: More than one token found"

echo "secret_names: ${secret_token_name[@]}"

else

k8s_secret=$(kubectl -n "$k8s_namespace" describe secret "$secret_token_name")

token=$(echo "$k8s_secret" | grep -E '^token:' | cut -f2 -d':' | xargs echo -n)

echo "message: Token found! This is copied to your clipboard"

echo "secret_name: $secret_token_name"

echo "secret_token: $token"

$(echo "$token" | pbcopy)

fi

fi

}

for i in "$@"

do

case $i in

-n=*)

NAMESPACE="${i#*=}"

shift # past argument=value

;;

-q=*)

QUERY="${i#*=}"

shift # past argument=value

;;

-d)

DASHBOARD_DEFAULT="true"

shift # help

;;

-h)

HELP="true"

shift # help

;;

*)

# unknown option

;;

esac

done

if [[ "$DASHBOARD_DEFAULT" ]] ; then

get_k8s_secret kube-system kubernetes-dashboard-token

elif [[ "$NAMESPACE" && "$QUERY" ]] ; then

get_k8s_secret "$NAMESPACE" "$QUERY"

elif [[ -z "$DASHBOARD_DEFAULT" || -z "$NAMESPACE" || -z "$QUERY" || "$HELP" ]] ; then

echo -e "You need to set some of the following paramaters:\n"

echo "Usage: $0"

echo -e "\t-d - The Default Dashboard query. The following parameters are set -n 'kube-system' -q 'kubernetes-dashboard-token'"

echo -e "\t-n - The kubernetes namespace"

echo -e "\t-q - The kubernetes secret name to query"

echo -e "\t-h - Help"

exit 1

fi

Here is how we use it:

k8s-token

-d - The Default Dashboard query. The following parameters are set -n 'kube-system' -q 'kubernetes-dashboard-token'

-n - The kubernetes namespace

-q - The kubernetes secret name to query

-h - Help

That should print:

query:

namespace: kube-system

query_name: kubernetes-dashboard-token

message: Token found! This is copied to your clipboard

secret_name: kubernetes-dashboard-token-wxyz