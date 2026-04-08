#!/usr/bin/env bash

set -euo pipefail

host="$GITLAB_HOST"
token="$GITLAB_TOKEN"
out="${XDG_CACHE_HOME:-$HOME/.cache}/gitlab-mirror/$host"

function say {
	echo -e "\e[34;1m$1\e[0m"
}

# reuse one ssh connection
export GIT_SSH_COMMAND="ssh -o ControlMaster=auto -o ControlPath=/tmp/git-ssh-cm-$$ -o ControlPersist=10"

mkdir -p "$out"

start=$(date +%s)

say "getting a list of all projects"
total_pages=$(curl -sI --header "PRIVATE-TOKEN: $token" \
	"https://$host/api/v4/projects?per_page=100&page=1" |
	grep -i '^x-total-pages:' | tr -d '\r' | awk '{print $2}')

all_pages=""
for page_num in $(seq 1 "$total_pages"); do
	say "listing page $page_num / $total_pages"
	url="https://$host/api/v4/projects?per_page=100&page=$page_num"
	page=$(curl -s --header "PRIVATE-TOKEN: $token" "$url" |
		jq -r '.[] | "\(.path_with_namespace)\t\(.ssh_url_to_repo)"')
	if test -z "$page"; then
		break
	fi
	all_pages+="$page"$'\n'
done

repos=$(echo "$all_pages" | grep -v '^[[:space:]]*$' | sort)
echo "$repos" | column -t -s $'\t' >"$out"/repos.txt

say "found $(wc -l <<<"$repos") projects"

while IFS=$'\t' read -r path url; do
	target="$out/$path"
	if test -d "$target/.git"; then
		say "updating '$url' at '$target'"
		pushd "$target" >/dev/null
		git fetch --depth 1 || true
		git reset --hard origin/HEAD || true
		git clean -fdx
		popd >/dev/null
	else
		say "cloning '$url' into '$target'"
		git clone "$url" "$target" --depth 1 || true
	fi
done <<<"$repos"

end=$(date +%s)
duration=$(echo $((end - start)) | awk '{print int($1/60)"min "int($1%60)"sec"}')

say "done in $duration"
