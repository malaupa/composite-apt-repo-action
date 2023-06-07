#!/usr/bin/bash

set -e

CACHE_DIR="./cache"
DOWNLOAD_COUNT=0

# downloads a asset file
download_release () {
  local repo=$1
  local release=$2
  local cache_file=$3
  local tag=$(echo $release | jq -rc ".tag_name")
  local assets=($(echo $release | jq -rc ".assets[]"))
  if ! [[ ${#assets[@]} == 0 ]]; then
    for asset in ${assets[@]}
    do
      echo "Downloading: $asset"
      curl -sLO "$asset"
      echo "$tag" >> "$cache_file"
      DOWNLOAD_COUNT=$((DOWNLOAD_COUNT+1))
    done
  else
    echo "Nothing to download for $repo#$tag"
  fi
}

# checks repo releases and triggers download of new assets
check_repo () {
  local repo=$1
  local pattern=$2
  pattern="${pattern//\\/"\\\\"}"
  local cache_file="$CACHE_DIR/${repo//\//"_"}"
  # fetch releases
  local response=$(curl -s -L -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/$repo/releases")
  # read releases
  readarray -t latest_releases < <(echo $response | jq -rc ".[] | select(.prerelease!=true) | {tag_name,assets} | .assets |= (map(select(.browser_download_url | test(\"$pattern\")) | .browser_download_url))")

  if ! [[ ${#latest_releases[@]} == 0 ]]; then
    # use only newest release
    local release=${latest_releases[0]}
    local tag=$(echo $release | jq -rc ".tag_name")
    if ! [[ $(grep -sx "$tag" "$cache_file") ]]; then
      download_release $repo $release $cache_file
    else
      echo "Tag already exists: $repo#$tag. Skip download."
    fi
  else
    echo "No releases found for $repo"
  fi
}

# starts process
main () {
  local pattern=$1
  shift
  
  if ! [[ -d "$CACHE_DIR" ]]; then
    mkdir $CACHE_DIR
  fi

  for repo in $@
  do
    check_repo $repo $pattern
  done

  if [[ $DOWNLOAD_COUNT > 0 ]]; then
    echo "result=true" >> $GITHUB_OUTPUT
  else
    echo "result=false" >> $GITHUB_OUTPUT
  fi
}

main $@
