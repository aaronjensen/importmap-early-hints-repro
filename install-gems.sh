#!/usr/bin/env bash

set -eEuo pipefail

trap 'printf "\n\e[31mError: Exit Status %s (%s)\e[m\n" $? "$(basename "$0")"' ERR

cd "$(dirname "$0")"

function boolean-var {
  variable_name=$1
  default=${2:-no}

  val=${!variable_name:=$default}

  if [[ "n|no|f|false|off|0" =~ $val ]]; then
    echo 'false'
  elif [[ "y|yes|t|true|on|1" =~ $val ]]; then
    echo 'true'
  else
    echo "Variable \$$variable_name is set to \`$val' which is not a boolean value" >&2
    echo >&2
    exit 1
  fi
}

if [ -z ${REMOVE_GEMS+x} ]; then
  echo
  echo "REMOVE_GEMS is not set. Using \"on\" by default."
  remove_gems="on"
else
  remove_gems=$REMOVE_GEMS
fi

gem_dir="./gems"

echo
echo "Install Gems"
echo "= = ="

if [ -z ${POSTURE+x} ]; then
  echo "POSTURE is not set. Using \"operational\" by default."
  posture="operational"
else
  posture=$POSTURE
fi

echo "Posture: $posture"
echo "Gem Directory: $gem_dir"
echo "Remove Gems: $remove_gems"

echo

echo "Removing bundler configuration"
echo "- - -"

cmd="rm -rfv ./.bundle"

echo $cmd
($cmd)

echo
echo "Removing Gemfile.lock"
echo "- - -"

cmd="rm -fv Gemfile.lock"

echo $cmd
($cmd)

remove_gems=$(boolean-var remove_gems)

if $remove_gems; then
  echo
  echo "Removing installed gems"
  echo "- - -"

  cmd="rm -rf $gem_dir"

  echo $cmd
  ($cmd)
fi

echo "Setting bundler path"
echo "- - -"

cmd="bundle config set --local path ./gems"

echo $cmd
($cmd)

echo
echo "Installing bundle"
echo "- - -"

if [ operational == "$posture" ]; then
  cmd="bundle config set --local without development test"

  echo $cmd
  ($cmd)
fi

cmd="bundle install --standalone"

echo $cmd
($cmd)

printf '\n\e[32mDone (%s)\e[m\n' "$(basename "$0")"
