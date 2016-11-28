#!/bin/sh

default()
{
  # Add paths to env (non-Travis build)
  if [ -z "$TRAVIS" ]; then
    PATH=/bin:/usr/bin:/usr/local/bin:$PATH
    export PATH
  fi

  SCRIPT=`basename $0`
  SCRIPT_DIR=`dirname $0`
  SCRIPT_DIR=`cd $SCRIPT_DIR; pwd`

  . $SCRIPT_DIR/env.sh
  . $SCRIPT_DIR/common.sh

  BOWER_JSON=bower.json
  PACKAGE_JSON=package.json
  SHRINKWRAP_JSON=npm-shrinkwrap.json

  TMP_DIR="/tmp/patternfly-releases"
  PTNFLY_DIR="$TMP_DIR/rcue"
  VERIFY_DIR="$TMP_DIR/rcue-verify"

  # For Travis, build the current repo instead of using a clone.
  if [ -n "$TRAVIS" ]; then
    PTNFLY_DIR=`cd $SCRIPT_DIR/../..; pwd`
  fi
}

# Bump version number in bower.json
#
bump_bower()
{
  echo "*** Bumping version in $BOWER_JSON to $VERSION"
  cd $PTNFLY_DIR

  sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $BOWER_JSON | \
  sed "s|\"patternfly\":.*|\"patternfly\": \"$PTNFLY_PKG_REPO$VERSION\"|" > $BOWER_JSON.tmp
  check $? "Version bump failure"

  mv $BOWER_JSON.tmp $BOWER_JSON
}

# Bump version number in package.json
#
bump_package()
{
  echo "*** Bumping version in $PACKAGE_JSON to $VERSION"
  cd $PTNFLY_DIR

  sed "s|\"version\":.*|\"version\": \"$VERSION\",|" $PACKAGE_JSON | \
  sed "s|\"patternfly\":.*|\"patternfly\": \"$PTNFLY_PKG_REPO$VERSION\"|" > $PACKAGE_JSON.tmp
  check $? "Version bump failure"

  mv $PACKAGE_JSON.tmp $PACKAGE_JSON
}

# Clean dependencies
#
clean()
{
  echo "*** Cleaning dependencies"
  cd $PTNFLY_DIR

  if [ -z "$TRAVIS" ]; then
    # Clean npm and bower installs (non-Travis build)
    npm cache clean
    bower cache clean

    # Remove for repo rebuild
    if [ -d node_modules ]; then
      rm -rf node_modules
    fi
    if [ -d components ]; then
      rm -rf components
    fi
  fi

  # shrinkwrap
  if [ -s $SHRINKWRAP_JSON ]; then
    rm -f $SHRINKWRAP_JSON
  fi
}

# Commit changes prior to bower verify step
#
commit()
{
  echo "*** Committing changes"
  cd $PTNFLY_DIR

  git add -u
  git commit -m "Bumped version number to $VERSION"
}

# Test prerequisites
#
prereqs()
{
  JUNK=`which npm`
  check $? "Cannot find npm in path"

  JUNK=`which bower`
  check $? "Cannot find bower in path"

  JUNK=`which grunt`
  check $? "Cannot find grunt in path"

  # Test for jekyll (non-Travis build)
  if [ -z "$TRAVIS" ]; then
    JUNK=`which jekyll`
    check $? "Cannot find jekyll in path"
  fi
}

# Push changes to remote repo (non-Travis build)
#
push()
{
  if [ -n "$TRAVIS" ]; then
    return
  fi

  echo "*** Pushing changes to $PTNFLY_REPO_SLUG"
  cd $PTNFLY_DIR

  git push --set-upstream origin $BRANCH --force
  check $? "git push failure"

  echo "*** Changes pushed to the $BRANCH branch of $PTNFLY_REPO_SLUG"
  echo "*** Review changes and create a PR via GitHub"
}

# Setup local repo (non-Travis build)
#
setup_repo() {
  if [ -n "$TRAVIS" ]; then
    return
  fi

  echo "*** Setting up local repo $PTNFLY_DIR"
  rm -rf $PTNFLY_DIR

  mkdir -p $TMP_DIR
  cd $TMP_DIR

  git clone https://github.com/$PTNFLY_REPO_SLUG.git
  check $? "git clone failure"

  cd $PTNFLY_DIR
  git checkout $BRANCH
  if [ "$?" -ne 0 ]; then
    git checkout -B $BRANCH
  fi
  check $? "git checkout failure"
}

# Shrink wrap npm and run vulnerability test
#
shrinkwrap()
{
  echo "*** Shrink wrapping $SHRINKWRAP_JSON"
  cd $PTNFLY_DIR

  # Don't shrinkwrap dev dependencies
  npm prune -production

  npm shrinkwrap
  check $? "npm shrinkwrap failure"

  # Restore for testing
  npm install
}

usage()
{
cat <<- EEOOFF

    This script will bump the repo version numbers, build, shrinkwrap, test, install, and push to GitHub.

    Note: After changes are pushed, a PR will need to be created via GitHub.

    sh [-x] $SCRIPT [-h|p|f|s] -v <version>

    Example: sh $SCRIPT -v 3.15.0 -f

    OPTIONS:
    h       Display this message (default) 
    f       Force push new branch to GitHub (e.g., bump-v3.15.0)
    p       Publish to npm (not valid with -s or -v)
    s       Skip new clone, clean, and install to rebuild previously created repo
    v       The version number (e.g., 3.15.0)

EEOOFF
}

# Verify bower installs
#
verify()
{
  echo "*** Verifying install"
  rm -rf $VERIFY_DIR

  mkdir -p $VERIFY_DIR
  cd $VERIFY_DIR

  bower install $PTNFLY_DIR/bower.json
  check $? "bower install failure"
}

# main()
{
  default

  if [ "$#" -eq 0 ]; then
    usage
    exit 1
  fi

  while getopts hfpsv c; do
    case $c in
      h) usage; exit 0;;
      f) PUSH=1;;
      s) SKIP_SETUP=1;;
      v) VERSION=$2; shift
         BRANCH=bump-v$VERSION;;
      \?) usage; exit 1;;
    esac
  done

  if [ -z "$VERSION" ]; then
    usage
    exit 1
  fi

  prereqs

  if [ -z "$SKIP_SETUP" ]; then
    setup_repo
  fi

  bump_bower
  bump_package

  if [ -z "$SKIP_SETUP" ]; then
    clean
    build_install
  fi

  build
  shrinkwrap
  build_test
  commit
  verify

  # Push changes to remote branch
  if [ -n "$PUSH" ]; then
    push
  fi

  if [ -z "$TRAVIS" ]; then
    echo "*** Remove $TMP_DIR directory manually after testing"
  fi
}
