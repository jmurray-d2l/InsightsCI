#!/bin/sh

# generate_tag.sh
# This script will find the current version from the package.json file.
# If we are on the master branch of the given repo, we generate a tag from the CURRENT_VERSION and TRAVIS_BUILD_NUMBER
# This script will also delete any local-only tags, this allows us to delete tags without having the build process recommitting the tags.
# Finally we push the newly created tag.

createTag() {
  export GIT_TAG=v$1
  git tag -l | xargs git tag -d
  git fetch
  git tag $GIT_TAG -a -m "$2"
}

push() {
  git push -q https://$GITHUB_RELEASE_TOKEN@github.com/Brightspace/$REPO_NAME --follow-tags
}

updateVersion() {
  npm i -g semver
  NEW_VERSION=$(semver $1 -i $2)
  sed -i 's/\("version": "\)[^"]*\("\)/\1'"$NEW_VERSION"'\2/g' package.json
  git diff package.json
  git commit -m "[skip ci] Updated version to $NEW_VERSION" package.json --verbose
}

setGitUser() {
  git config --global user.email "BrightspaceGitHubReader@d2l.com"
  git config --global user.name "BrightspaceGitHubReader"
  git config --global push.default simple
  git checkout $TRAVIS_BRANCH
}

if [ "$TRAVIS_BRANCH" = "CITagging" ] && [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
  CURRENT_VERSION=$(grep -Po '(?<="version": ")[^"]*' package.json)
  LAST_MESSAGE=$(git log -1 --oneline)
  UPDATE_TYPE=minor
  UPDATE_TYPE_OVERRIDE=$(echo $LAST_MESSAGE | grep -oP '(?:(?<=\[).+?(?=\]))')
  echo "Debug - Last message is: $LAST_MESSAGE"
  echo "Debug - Override is: $UPDATE_TYPE_OVERRIDE"

  if [ "$UPDATE_TYPE_OVERRIDE" = "increment major" ]; then
    UPDATE_TYPE=major
  fi

  if [ "$UPDATE_TYPE_OVERRIDE" = "increment patch" ]; then
    UPDATE_TYPE=patch
  fi

  setGitUser
  updateVersion $CURRENT_VERSION $UPDATE_TYPE
  createTag $NEW_VERSION $LAST_MESSAGE
  push
fi
