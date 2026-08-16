#!/usr/bin/env bash

set -e

# USAGE:
# - Set PLUGINS_DIR to wherever OpenplanetNext/Plugins lives
# ./build.sh [dev|release]
# Defaults to `dev` build mode.

# https://greengumdrops.net/index.php/colorize-your-bash-scripts-bash-color-library/
source ./vendor/_colors.bash

_build_mode=${1:-dev}

case $_build_mode in
  dev|release|prerelease|unittest)
    ;;
  *)
    _colortext16 red "⚠ Error: build mode of '$_build_mode' is not a valid option.\n\tOptions: dev, release.";
    exit -1;
    ;;
esac

_colortext16 yellow "🚩 Build mode: $_build_mode"

_colortext16 green "🏗️ preprocessing .Script.txt files in ml-scripts"

python3 ./pre-proc-scripts.py

pluginSources=( 'src' )

for pluginSrc in ${pluginSources[@]}; do
  TOML_RAW="$(tr -d '\r' < ./info.toml)"
  PLUGIN_PRETTY_NAME="$(printf '%s\n' "$TOML_RAW" | grep '^name' | cut -f 2 -d '=' | tr -d '\"\r' | sed 's/^[[:space:]]*//')"
  PLUGIN_VERSION="$(printf '%s\n' "$TOML_RAW" | grep '^version' | cut -f 2 -d '=' | tr -d '\"\r' | sed 's/^[[:space:]]*//')"

  # prelim stuff
  case $_build_mode in
    dev)
      # we will replicate this in the info.toml file later
      export PLUGIN_PRETTY_NAME="${PLUGIN_PRETTY_NAME:-} (Dev)"
      ;;
    prerelease)
      export PLUGIN_PRETTY_NAME="${PLUGIN_PRETTY_NAME:-} (Prerelease)"
      ;;
    unittest)
      export PLUGIN_PRETTY_NAME="${PLUGIN_PRETTY_NAME:-} (UnitTest)"
      ;;
    *)
      ;;
  esac

  echo
  _colortext16 green "✅ Building: ${PLUGIN_PRETTY_NAME} (./$pluginSrc)"

  # remove parens, replace spaces with dashes, and uppercase characters with lowercase ones
  # => `Never Give Up (Dev)` becomes `never-give-up-dev`
  PLUGIN_NAME=$(echo "$PLUGIN_PRETTY_NAME" | tr -d '(),;'\''"' | tr 'A-Z ' 'a-z-')
  # echo $PLUGIN_NAME
  _colortext16 green "✅ Output file/folder name: ${PLUGIN_NAME}"

  BUILD_NAME=$PLUGIN_NAME-$(date +%s).zip
  RELEASE_NAME=$PLUGIN_NAME-$PLUGIN_VERSION.op
  PLUGINS_DIR=${PLUGINS_DIR:-$HOME/win/OpenplanetNext/Plugins}
  PLUGIN_DEV_LOC=$PLUGINS_DIR/ghosts-pp
  PLUGIN_RELEASE_LOC=$PLUGINS_DIR/$RELEASE_NAME

  function buildPlugin {
    python3 - "$BUILD_NAME" "$RELEASE_NAME" "$pluginSrc" <<'PY'
import os, sys, zipfile
archive_name = sys.argv[1]
release_name = sys.argv[2]
plugin_src = sys.argv[3]
with zipfile.ZipFile(archive_name, 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(plugin_src):
        for name in files:
            full = os.path.join(root, name)
            arc = os.path.relpath(full, plugin_src)
            zf.write(full, arc)
    for extra in ('LICENSE', 'README.md'):
        if os.path.exists(extra):
            zf.write(extra, extra)

os.replace(archive_name, release_name)
PY

    cp -v $RELEASE_NAME $PLUGINS_DIR/$RELEASE_NAME

    _colortext16 green "\n✅ Built plugin as ${BUILD_NAME} and copied to ./${RELEASE_NAME}.\n"
  }

  # this case should set both _copy_exit_code and _build_dest

  # common for non-release builds
  case $_build_mode in
    dev|prerelease|unittest)
      # in case it doesn't exist
      _build_dest=$PLUGIN_DEV_LOC
      mkdir -p $_build_dest/
      rm -vr $_build_dest/* || true
      cp -LR -v ./$pluginSrc/* $_build_dest/
      # cp -LR -v ./external/* $_build_dest/
      cp -LR -v ./info.toml $_build_dest/
      python3 - "$RELEASE_NAME" "$PLUGINS_DIR" "$pluginSrc" <<'PY'
import os, sys, zipfile
release_name = sys.argv[1]
plugins_dir = sys.argv[2]
plugin_src = sys.argv[3]
archive_path = os.path.join(plugins_dir, release_name)
with zipfile.ZipFile(archive_path, 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(plugin_src):
        for name in files:
            full = os.path.join(root, name)
            arc = os.path.relpath(full, plugin_src)
            zf.write(full, arc)
    for extra in ('LICENSE', 'README.md', 'info.toml'):
        if os.path.exists(extra):
            zf.write(extra, extra)
PY
      _copy_exit_code="$?"
      ;;
  esac

  case $_build_mode in
    dev)
      python3 - "$_build_dest/info.toml" "DEV" <<'PY'
import re, sys
path = sys.argv[1]
mode = sys.argv[2]
with open(path, 'r', encoding='utf-8', newline='') as f:
    text = f.read()
text = re.sub(r'^(name\s*=\s*")([^"]+)(")', r'\1\2 (Dev)\3', text, count=1, flags=re.M)
text = text.replace('#__DEFINES__', 'defines = ["' + mode + '"]', 1)
with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(text)
PY
      ;;
    prerelease)
      python3 - "$_build_dest/info.toml" "RELEASE" <<'PY'
import re, sys
path = sys.argv[1]
mode = sys.argv[2]
with open(path, 'r', encoding='utf-8', newline='') as f:
    text = f.read()
text = re.sub(r'^(name\s*=\s*")([^"]+)(")', r'\1\2 (Prerelease)\3', text, count=1, flags=re.M)
text = text.replace('#__DEFINES__', 'defines = ["' + mode + '"]', 1)
with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(text)
PY
      ;;
    unittest)
      python3 - "$_build_dest/info.toml" "UNIT_TEST" <<'PY'
import re, sys
path = sys.argv[1]
mode = sys.argv[2]
with open(path, 'r', encoding='utf-8', newline='') as f:
    text = f.read()
text = re.sub(r'^(name\s*=\s*")([^"]+)(")', r'\1\2 (UnitTest)\3', text, count=1, flags=re.M)
text = text.replace('#__DEFINES__', 'defines = ["' + mode + '"]', 1)
with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(text)
PY
      ;;
    release)
      cp ./info.toml ./$pluginSrc/info.toml
      python3 - "./$pluginSrc/info.toml" "RELEASE" <<'PY'
import re, sys
path = sys.argv[1]
mode = sys.argv[2]
with open(path, 'r', encoding='utf-8', newline='') as f:
    text = f.read()
text = text.replace('#__DEFINES__', 'defines = ["' + mode + '"]', 1)
with open(path, 'w', encoding='utf-8', newline='') as f:
    f.write(text)
PY
      buildPlugin
      rm ./$pluginSrc/info.toml
      _build_dest=$PLUGIN_RELEASE_LOC
  cp -v "$RELEASE_NAME" "$_build_dest"
      # todo: how do we do the release __defines thing?
      _copy_exit_code="$?"
      ;;
    *)
      _colortext16 red "\n⚠ Error: unknown build mode: $_build_mode"
  esac


  echo ""
  if [[ "$_copy_exit_code" != "0" ]]; then
    echo $PLUGIN_PRETTY_NAME
    _colortext16 red "⚠ Error: could not copy plugin to Trackmania directory. You might need to click\n\t\`F3 > Scripts > TogglePlugin > PLUGIN\`\nto unlock the file for writing."
    _colortext16 red "⚠   Also, \"Stop Recent\" and \"Reload Recent\" should work, too, if the plugin is the \"recent\" plugin."
  else
    _colortext16 green "✅ Release file: ${RELEASE_NAME}"
  fi


  # # cleanup
  # case $_build_mode in
  #   dev)
  #     # remove the build artifact b/c they'll just take up space
  #     (rm $BUILD_NAME && _colortext16 green "✅ Removed ${BUILD_NAME}") || _colortext16 red "Failed to remove ${BUILD_NAME}."
  #     ;;
  #   *)
  #     ;;
  # esac

done

_colortext16 green "✅ Done."
