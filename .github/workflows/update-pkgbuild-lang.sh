_url=https://ftp.mozilla.org/pub/firefox/nightly
function update(){
    echo $1
    echo $2
    local _version=$(curl ${_url}/latest-mozilla-central-l10n/linux-x86_64/xpi/ | grep "${1}.langpack.xpi" | sed "s/^.*>firefox-//; s/\.$1.*//" | sort -n | tail -n 1)
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
    echo "pkgver=$(printf "%s.%s.%s" ${_version} ${_build_id_date} ${_build_id_time})"
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
}

_languages=(
  'ach    "Acholi"'
  'af     "Afrikaans"'
  'an     "Aragonese"'
  'ar     "Arabic"'
  'ast    "Asturian"'
  'az     "Azerbaijani"'
  'be     "Belarusian"'
  'bg     "Bulgarian"'
  'bn     "Bengali"'
  'br     "Breton"'
  'bs     "Bosnian"'
  'ca-valencia "Catalan (Valencian)"'
  'ca     "Catalan"'
  'cak    "Maya Kaqchikel"'
  'cs     "Czech"'
  'cy     "Welsh"'
  'da     "Danish"'
  'de     "German"'
  'dsb    "Lower Sorbian"'
  'el     "Greek"'
  'en-CA  "English (Canadian)"'
  'en-GB  "English (British)"'
  'eo     "Esperanto"'
  'es-AR  "Spanish (Argentina)"'
  'es-CL  "Spanish (Chile)"'
  'es-ES  "Spanish (Spain)"'
  'es-MX  "Spanish (Mexico)"'
  'et     "Estonian"'
  'eu     "Basque"'
  'fa     "Persian"'
  'ff     "Fulah"'
  'fi     "Finnish"'
  'fr     "French"'
  'fy-NL  "Frisian"'
  'ga-IE  "Irish"'
  'gd     "Gaelic (Scotland)"'
  'gl     "Galician"'
  'gn     "Guarani"'
  'gu-IN  "Gujarati (India)"'
  'he     "Hebrew"'
  'hi-IN  "Hindi (India)"'
  'hr     "Croatian"'
  'hsb    "Upper Sorbian"'
  'hu     "Hungarian"'
  'hy-AM  "Armenian"'
  'ia     "Interlingua"'
  'id     "Indonesian"'
  'is     "Icelandic"'
  'it     "Italian"'
  'ja     "Japanese"'
  'ka     "Georgian"'
  'kab    "Kabyle"'
  'kk     "Kazakh"'
  'km     "Khmer"'
  'kn     "Kannada"'
  'ko     "Korean"'
  'lij    "Ligurian"'
  'lt     "Lithuanian"'
  'lv     "Latvian"'
  'mk     "Macedonian"'
  'mr     "Marathi"'
  'ms     "Malay"'
  'my     "Burmese"'
  'nb-NO  "Norwegian (Bokmål)"'
  'ne-NP  "Nepali"'
  'nl     "Dutch"'
  'nn-NO  "Norwegian (Nynorsk)"'
  'oc     "Occitan"'
  'pa-IN  "Punjabi (India)"'
  'pl     "Polish"'
  'pt-BR  "Portuguese (Brazilian)"'
  'pt-PT  "Portuguese (Portugal)"'
  'rm     "Romansh"'
  'ro     "Romanian"'
  'ru     "Russian"'
  'si     "Sinhala"'
  'sk     "Slovak"'
  'sl     "Slovenian"'
  'son    "Songhai"'
  'sq     "Albanian"'
  'sr     "Serbian"'
  'sv-SE  "Swedish"'
  'ta     "Tamil"'
  'te     "Telugu"'
  'th     "Thai"'
  'tl     "Tagalog"'
  'tr     "Turkish"'
  'trs    "Chicahuaxtla Triqui"'
  'uk     "Ukrainian"'
  'ur     "Urdu"'
  'uz     "Uzbek"'
  'vi     "Vietnamese"'
  'xh     "Xhosa"'
  'zh-CN  "Chinese (Simplified)"'
  'zh-TW  "Chinese (Traditional)"'
)

for _lang in "${_languages[@]}"; do
    pwd
    eval "update $_lang"
done
