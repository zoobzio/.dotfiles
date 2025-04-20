#!/bin/bash

set -e 

cd $(git rev-parse --show-toplevel) | exit

echo "#> Started installing dotfiles..."

for d in */ ; do
  local_config=~/.config/${d%/}
  repo_config=$(pwd)/${d%/}
  rm -rf "${local_config}"
  ln -s "${repo_config}" "${local_config}"
done

rm -rf ~/.config/fish-ai.ini 
ln -s "${pwd}/fish-ai.ini" ~/.config/fish-ai.ini

echo "#> Finished installing dotfiles..."
