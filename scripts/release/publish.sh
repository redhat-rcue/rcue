#!/bin/sh

default()
{
  SCRIPT=`basename $0`
  SCRIPT_DIR=`dirname $0`
  SCRIPT_DIR=`cd $SCRIPT_DIR; pwd`

  . $SCRIPT_DIR/env.sh
  . $SCRIPT_DIR/common.sh

  PTNFLY_DIR=`cd $SCRIPT_DIR/../..; pwd`
}

# Push version bump changes to master branch
#
push_master()
{
  echo "*** Pushing to master"
  cd $PTNFLY_DIR

  # Note: Changes are committed by release script prior to bower install verification

  # Merge master branch
  git fetch upstream master:master # <remote-branch>:<local-branch>
  git checkout master
  git merge -Xtheirs $TRAVIS_BRANCH-local --no-edit --ff
  check $? "git merge failure"

  # Push to master
  git push upstream master:master
  check $? "git push failure"
}

usage()
{
cat <<- EEOOFF

    This script will publish generated files to GitHub.

    Note: Intended for use with Travis only.

    sh [-x] $SCRIPT [-h]

    Example: sh $SCRIPT

    OPTIONS:
    h       Display this message (default)

EEOOFF
}

# main()
{
  default

  while getopts hbd c; do
    case $c in
      h) usage; exit 0;;
      \?) usage; exit 1;;
    esac
  done

  echo "This publish is running against $TRAVIS_REPO_SLUG"

  if [ -n "$TRAVIS_TAG" ]; then
    echo "This publish is running against $TRAVIS_TAG"

    # Get version from tag
    case "$TRAVIS_TAG" in
      $BUMP_TAG_PREFIX* ) VERSION=`echo "$TRAVIS_TAG" | cut -c $BUMP_TAG_PREFIX_COUNT-`;;
      *) check 1 "$TRAVIS_TAG is not a recognized format. Do not publish!";;
    esac
  fi

  # Ensure release runs for main repo only
  if [ "$TRAVIS_REPO_SLUG" != "$PTNFLY_REPO_SLUG" ]; then
    check 1 echo "Publish must be performed on $PTNFLY_REPO_SLUG only!"
  fi

  push_master # Push version bump to master
}
