#!/usr/bin/env bash
set -eo pipefail; [[ $DOKKU_TRACE ]] && set -x
export PLUGIN_COMMAND_PREFIX="couchdb"
export DOKKU_ROOT="~dokku"

wget https://raw.githubusercontent.com/dokku/dokku/master/bootstrap.sh
if [[ "$DOKKU_VERSION" == "master" ]]; then
  sudo bash bootstrap.sh
else
  sudo DOKKU_TAG="$DOKKU_VERSION" bash bootstrap.sh
fi
echo "Dokku version $DOKKU_VERSION"

source "$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")/config"
rm -rf "$DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX"
mkdir -p "$DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX" "$DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX/subcommands"
find ./ -maxdepth 1 -type f -exec cp '{}' "$DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX" \;
find ./subcommands -maxdepth 1 -type f -exec cp '{}' "$DOKKU_ROOT/plugins/$PLUGIN_COMMAND_PREFIX/subcommands" \;
echo "$DOKKU_VERSION" > $DOKKU_ROOT/VERSION
