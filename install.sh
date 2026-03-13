#!/bin/bash

set -e 

cd $(git rev-parse --show-toplevel) | exit

echo "#> Started installing dotfiles..."

for d in */ ; do
  local_config=~/.config/${d%/}
  repo_config=$(pwd)/${d%/}
  if [ -L "${local_config}" ]; then
    rm "${local_config}"
  elif [ -e "${local_config}" ]; then
    echo "#> Warning: ${local_config} exists and is not a symlink, skipping"
    continue
  fi
  ln -s "${repo_config}" "${local_config}"
done

if [ -L ~/.config/fish-ai.ini ]; then
  rm ~/.config/fish-ai.ini
elif [ -e ~/.config/fish-ai.ini ]; then
  echo "#> Warning: ~/.config/fish-ai.ini exists and is not a symlink, skipping"
fi
[ ! -e ~/.config/fish-ai.ini ] && ln -s "$(pwd)/fish-ai.ini" ~/.config/fish-ai.ini

if [ -L ~/.claude ]; then
  rm ~/.claude
elif [ -e ~/.claude ]; then
  echo "#> Warning: ~/.claude exists and is not a symlink, skipping"
fi
[ ! -e ~/.claude ] && ln -s "$(pwd)/claude" ~/.claude

echo "#> Finished installing dotfiles..."
