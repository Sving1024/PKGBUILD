echo $1
echo $2
local _url=https://ftp.mozilla.org/pub/firefox/nightly
local _version=$(curl ${_url}/latest-mozilla-central-l10n/linux-x86_64/xpi/ | grep "\.${1}.langpack.xpi" | sed "s/^.*>firefox-//; s/\.$1.*//" | sort -n | tail -n 1)
local _build_id_raw="$(curl -s "${_url}/latest-mozilla-central-l10n/firefox-${_version}.$1.linux-x86_64.checksums" | grep '.partial.mar' | cut -d' ' -f4 | grep -E -o '[[:digit:]]{14}' | sort | tail -n1)"
declare -A _build_id
local _build_id=(
    [year]="${_build_id_raw:0:4}"
    [month]="${_build_id_raw:4:2}"
    [day]="${_build_id_raw:6:2}"
    [hour]="${_build_id_raw:8:2}"
    [min]="${_build_id_raw:10:2}"
    [sec]="${_build_id_raw:12:2}"
    [date]="${_build_id_raw:0:8}"
    [time]="${_build_id_raw:8:6}"
)
local _build_id_date=${_build_id[date]}
local _build_id_time=${_build_id[time]}
local pkgver=$(printf "%s.%s.%s" ${_version} ${_build_id_date} ${_build_id_time})
echo "version=${_version}"
echo "pkgver=${pkgver}"
mkdir -p ./tmp/firefox-nightly-i18n-$1
cp firefox-nightly-i18n-base/PKGBUILD ./tmp/firefox-nightly-i18n-$1/PKGBUILD
pushd ./tmp/firefox-nightly-i18n-$1
    sed -i "s/pkgver=.*$/pkgver=${pkgver}/" PKGBUILD
    sed -i "s/_version=.*$/_version=${_version}/" PKGBUILD
    sed -i "s/_language=placeholder/_language=\"$2\"/" PKGBUILD
    sed -i "s/_language_short=placeholder/_language_short=$1/" PKGBUILD
#        cat PKGBUILD
    updpkgsums
#        makepkg
popd
if [ ! -d ./firefox-nightly-i18n/$1/ ]; then
    mkdir -p ./firefox-nightly-i18n/$1/
fi
if [ ! -f ./firefox-nightly-i18n/$1/PKGBUILD ]; then
    rm ./firefox-nightly-i18n/$1/PKGBUILD
fi
mv ./tmp/firefox-nightly-i18n-$1/PKGBUILD ./firefox-nightly-i18n/$1/PKGBUILD
rm -rf ./tmp/firefox-nightly-i18n-$1
