#!/usr/bin/env bash
echo "-------------------------------------"
echo "Phalcon Switcher"
echo "Version 1.0.0"
echo "By Adeyemi Olaoye <yemexx1@gmail.com>"
echo "-------------------------------------"

version_to_switch_to=$1

if [ -z ${version_to_switch_to} ]; then
    echo "Version not supplied"
    echo "Aborting..."
    exit
fi

echo "Version To switch to: ${version_to_switch_to}"

current_version=`php -r "echo phpversion('phalcon');"`

echo "Current Version: ${current_version}"

if [ ${current_version} == ${version_to_switch_to} ]; then
    echo "Already on ${current_version}"
    exit
fi

if [[ ${version_to_switch_to:0:1} == "3" ]]; then
    version_to_switch_to="v${version_to_switch_to}"
elif [ ${version_to_switch_to:0:1} == "1" ] || [ ${version_to_switch_to:0:1} == "2" ]; then
    version_to_switch_to="phalcon-v${version_to_switch_to}"
fi

if git ls-remote https://github.com/phalcon/cphalcon.git | grep -sw "${version_to_switch_to}" 2>&1>/dev/null; then
    echo "Starting source download..."
else
    echo "Phalcon version does not exit. Please check https://github.com/phalcon/cphalcon/releases for valid versions"
    echo "Aborting..."
    exit
fi

if [ -d "/usr/local/bin/cphalcon/cphalcon-${version_to_switch_to}" ]; then
    echo "Source already exists... "
else
    git clone -b "${version_to_switch_to}" --single-branch --depth 1 https://github.com/phalcon/cphalcon.git "/usr/local/bin/cphalcon/cphalcon-${version_to_switch_to}"
fi

cd "/usr/local/bin/cphalcon/cphalcon-${version_to_switch_to}"

echo "Source download complete. Starting build..."
cd build
sudo ./install

echo "Installing extension..."
extension_dir=`php-config --extension-dir`
scan_dir=`php --ini | grep "Scan"`
scan_dir=${scan_dir:35:${#scan_dir}}
echo "
[phalcon]
extension=${extension_dir}/phalcon.so
" | tee "${scan_dir}/ext-phalcon.ini" > /dev/null

echo "Install done!"
current_version=`php -r "echo phpversion('phalcon');"`
echo "Phalcon Version is now: ${current_version}"

echo "Remember to restart your webserver"
echo "Thank you for using Phalcon Switcher!"