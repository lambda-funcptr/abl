#!/bin/bash

cd $(dirname $0)

mkdir -p dist
pushd dist > /dev/null

echo ">>> Cloning/updating repo..."
if ! [[ -d linux ]]; then
  git clone -b linux-rolling-lts https://github.com/gregkh/linux.git --filter=blob:none --single-branch
else
  pushd linux > /dev/null
  git pull
  popd > /dev/null
fi

echo ">>> Copying existing config into build tree..."

popd > /dev/null

cp kernel.config dist/linux/.config

pushd dist/linux > /dev/null

make "$1"

popd > /dev/null

if ! diff kernel.config dist/linux/.config > /dev/null; then
  { echo "# !!! Kernel configuration changed!"; diff --color -u kernel.config dist/linux/.config; } | less -R
  echo -n "!!! Kernel configuration changed, copy changes? [y/n] "
  read -n1 copy_changes
  echo
  if [[ "${copy_changes}" == "y" ]]; then
    echo ">>> Copying changes..."
    cp dist/linux/.config kernel.config
  else
    timestamp="$(date -Is)"
    cp dist/linux/.config "dist/${timestamp}.config"
    echo ">>> Not copying changes, but backed up to dist/${timestamp}.config"
  fi
else
  echo ">>> No changes detected..."
fi