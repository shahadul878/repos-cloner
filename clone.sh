#!/bin/bash

# Get the directory of the script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Define arrays for plugin and theme repositories with only repository names
plugin_repos=(
  "ayyash-addons"
  "ayyash-addons-pro"
  "giftly-pro"
)

theme_repos=(
  "giftly"
)

# Define the target directories
plugins_dir="$script_dir/wp-content/plugins"
themes_dir="$script_dir/wp-content/themes"

# Function to prompt for repository URL
prompt_for_protocol() {
  if [ -z "$REPO_PROTOCOL" ]; then
    local protocol
    read -p "Enter the preferred protocol for repositories (HTTP/HTTPS or SSH): " protocol

    case "$protocol" in
      "http" | "https" | "ssh")
        export REPO_PROTOCOL="$protocol"
        ;;
      *)
        echo "Invalid protocol. Using default HTTPS."
        export REPO_PROTOCOL="https"
        ;;
    esac
  fi

  echo "$REPO_PROTOCOL"
}

# Set the protocol for the first time
preferred_protocol=$(prompt_for_protocol)

# Function to construct repository URL based on user preference
construct_repo_url() {
  local repo_name="$1"
  local protocol="$preferred_protocol"

  case "$protocol" in
    "http" | "https")
      echo "https://github.com/themeoo/$repo_name.git"
      ;;
    "ssh")
      echo "git@github.com:themeoo/$repo_name.git"
      ;;
    *)
      echo "Invalid protocol. Using default HTTPS."
      echo "https://github.com/themeoo/$repo_name.git"
      ;;
  esac
}

# Function to clone repositories
clone_repository() {
  local repo_name="$1"
  local repo_url="$2"
  local target_dir="$3"

  # Check if the target directory already exists
  if [ -d "$target_dir" ]; then
    echo "Error: Target directory '$target_dir' already exists. Skipping cloning for $repo_name."
  else
    # Clone the repository
    git clone "$repo_url" "$target_dir"

    # Check if the cloning was successful
    if [ $? -eq 0 ]; then
      echo "Cloned $repo_name to $target_dir successfully."
    else
      echo "Error: Failed to clone $repo_name to $target_dir."
    fi
  fi
}

# Clone plugin repositories
for repo_name in "${plugin_repos[@]}"; do
  repo_url=$(construct_repo_url "$repo_name")
  target_dir="$plugins_dir/$repo_name"
  clone_repository "$repo_name" "$repo_url" "$target_dir"
done

# Clone theme repositories
for repo_name in "${theme_repos[@]}"; do
  repo_url=$(construct_repo_url "$repo_name")
  target_dir="$themes_dir/$repo_name"
  clone_repository "$repo_name" "$repo_url" "$target_dir"
done