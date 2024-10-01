#!/bin/bash
# shellcheck disable=SC2024

set -o errexit -o pipefail -o nounset

#pkgname=$INPUT_PKGNAME
#pkgbuild=$INPUT_PKGBUILD
#assets=$INPUT_ASSETS
#updpkgsums=$INPUT_UPDPKGSUMS
#test=$INPUT_TEST
#read -r -a test_flags <<< "$INPUT_TEST_FLAGS"
#post_process=$INPUT_POST_PROCESS
#commit_username=$INPUT_COMMIT_USERNAME
#commit_email=$INPUT_COMMIT_EMAIL
#ssh_private_key=$INPUT_SSH_PRIVATE_KEY
#commit_message=$INPUT_COMMIT_MESSAGE
#allow_empty_commits=$INPUT_ALLOW_EMPTY_COMMITS
#force_push=$INPUT_FORCE_PUSH
#ssh_keyscan_types=$INPUT_SSH_KEYSCAN_TYPES

pkgname=firefox-nightly-i18n-${1,,}
pkgbuild=./firefox-nightly-i18n/${1}/PKGBUILD
assets=''
updpkgsums='false'
test='true'
TEST_FLAGS='--clean --cleanbuild --nodeps'
read -r -a test_flags <<< $TEST_FLAGS
commit_username="github-actions[bot]"
commit_email='github-actions[bot]@users.noreply.github.com'
echo "$(cat ${pkgbuild} | grep pkgver)"
eval "$(cat ${pkgbuild} | grep pkgver)"
commit_message="update to ${pkgver}"
allow_empty_commits='false'
force_push='false'
post_process=''

assert_non_empty() {
  name=$1
  value=$2
  if [[ -z "$value" ]]; then
    echo "::error::Invalid Value: $name is empty." >&2
    exit 1
  fi
}

assert_non_empty inputs.pkgname "$pkgname"
assert_non_empty inputs.pkgbuild "$pkgbuild"
assert_non_empty inputs.commit_username "$commit_username"
assert_non_empty inputs.commit_email "$commit_email"
#assert_non_empty inputs.ssh_private_key "$ssh_private_key"

export HOME=/home/builder

echo '::group::Configuring Git'
git config --global user.name "$commit_username"
git config --global user.email "$commit_email"
echo '::endgroup::'

echo '::group::Cloning AUR package into /tmp/local-repo'
git clone -v "https://aur.archlinux.org/${pkgname}.git" /tmp/local-repo
echo '::endgroup::'

echo '::group::Copying files into /tmp/local-repo'
{
  echo "Copying $pkgbuild"
  cp -r "$pkgbuild" /tmp/local-repo/
}
# shellcheck disable=SC2086
# Ignore quote rule because we need to expand glob patterns to copy $assets
if [[ -n "$assets" ]]; then
  echo 'Copying' $assets
  cp -rt /tmp/local-repo/ $assets
fi
echo '::endgroup::'

if [ "$updpkgsums" == "true" ]; then
	echo '::group::Updating checksums'
	cd /tmp/local-repo/
	updpkgsums
	echo '::endgroup::'
fi

if [ "$test" == "true" ]; then
	echo '::group::Building package with makepkg'
	cd /tmp/local-repo/
	makepkg "${test_flags[@]}"
	echo '::endgroup::'
fi

echo '::group::Generating .SRCINFO'
cd /tmp/local-repo
makepkg --printsrcinfo >.SRCINFO
echo '::endgroup::'

if [ -n "$post_process" ]; then
	echo '::group::Executing post process commands'
	cd /tmp/local-repo/
  eval "$post_process"
	echo '::endgroup::'
fi

echo '::group::Committing files to the repository'
if [[ -z "$assets" ]]; then
  # When $assets are not set, we can add just PKGBUILD and .SRCINFO
  # This is to prevent unintended behaviour and maintain backwards compatibility
  git add -fv PKGBUILD .SRCINFO
else
  # We cannot just re-use $assets because it contains absolute paths outside repository
  # But we can just add all files in the repository which should also include all $assets
  git add --all
fi

case "$allow_empty_commits" in
true)
  git commit --allow-empty -m "$commit_message"
  ;;
false)
  git diff-index --quiet HEAD || git commit -m "$commit_message" # use `git diff-index --quiet HEAD ||` to avoid error
  ;;
*)
  echo "::error::Invalid Value: inputs.allow_empty_commits is neither 'true' nor 'false': '$allow_empty_commits'"
  exit 2
  ;;
esac
echo '::endgroup::'

echo '::group::Publishing the repository'
git remote add aur "ssh://aur@aur.archlinux.org/${pkgname}.git"
case "$force_push" in
true)
  git push -v --force aur master
  ;;
false)
  git push -v aur master
  ;;
*)
  echo "::error::Invalid Value: inputs.force_push is neither 'true' nor 'false': '$force_push'"
  exit 3
  ;;
esac
echo '::endgroup::'

rm -rf /tmp/local-repo