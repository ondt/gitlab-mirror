# `gitlab-mirror`

A simple tool that mass-clones all repos from a GitLab instance.

Cloning the entire GitLab instance allows me to use tools like `ripgrep` to search for stuff across all repos locally.

## Setup

1. Add `export GITLAB_HOST="gitlab.company.com"` and `export GITLAB_TOKEN="..."` to your profile or bashrc.
2. Run `nix profile add github:ondt/gitlab-mirror` to install this tool.

## Usage

Run `gitlab-mirror`, it downloads or updates the local mirror of the GitLab instance.

The mirror is saved to `~/.cache/gitlab-mirror/gitlab.company.com`.

## Disclaimer

This software is provided "as is", without warranty of any kind, and the author shall not be held liable for any damages
arising from its use.
