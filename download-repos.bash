#!/usr/bin/env bash

target=$1

if [ -z "$target" ]; then
	echo "Error: Directory argument not provided."
	exit 1
fi

if [ ! -d "$target" ]; then
	echo "Error: '$target' is not a directory."
	exit 1
fi

index_file="$target"/index.txt

export GITLAB_HOST="gitlab.ii.zone"

all_pages=""
for page_num in $(seq 1 9999999); do
	echo "listing page $page_num"
	page=$(glab repo list --all --per-page=100 --page="$page_num")
	line_count=$(echo "$page" | wc -l)
	if ((line_count <= 2)); then
		break
	fi
	all_pages+="$page"$'\n'
done

repos=$(echo "$all_pages" | cut -f1-2 | grep -v '^[[:space:]]*$' | sed -r 's/([^\t])\t([^\t])/\1\t\2/;t;d' | sort)

count=$(echo "$repos" | wc -l)
echo "found $count projects"

echo "$repos" | column -t -s $'\t' >"$index_file"

while IFS=$'\t' read -r path url; do
	echo "cloning $url into $path"
	git clone "$url" "$target/$path"
done <<<"$repos"
