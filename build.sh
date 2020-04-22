#!/usr/bin/env bash
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

SOFTWARE_NAME="caddy"
VERSION_MAJOR="1"
VERSION_MINOR="0"
VERSION_PATCH="4"
SEM_VER="${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}"
DEB_VER="${VERSION_MAJOR}.${VERSION_MINOR}-${VERSION_PATCH}"
PKG_NAME="${SOFTWARE_NAME}_${DEB_VER}"
PKG_DIR="pkg/${SOFTWARE_NAME}_${DEB_VER}"

function download_artifact {
    printf "Downloading artifact..."
    rm -rf ./artifact
    mkdir -p ./artifact
    wget -q "https://github.com/caddyserver/caddy/releases/download/v${SEM_VER}/caddy_v${SEM_VER}_linux_amd64.tar.gz" \
        -O "./artifact/caddy.tar.gz"
    echo "OK"
}

function extract_files_from_artifact {(
    printf "Extracting files from artifact..."
    cd ./artifact
    tar -xvzf ./caddy.tar.gz > /dev/null
    echo "OK"
)}

function copy_files_to_package_directory {(
    printf "Copying files to package directory..."
    rm -rf $PKG_DIR
    mkdir -p "./${PKG_DIR}/DEBIAN"
    mkdir -p "./${PKG_DIR}/usr/bin"
    mkdir -p "./${PKG_DIR}/etc/systemd/system"
    mkdir -p "./${PKG_DIR}/etc/caddy/conf"
    mkdir -p "./${PKG_DIR}/etc/caddy/ssl"

    (
        export PACKAGE="${SOFTWARE_NAME}"
        export VERSION="${DEB_VER}"
        envsubst < "./assets/control.tpl" > "./${PKG_DIR}/DEBIAN/control"
    )
    cp "./artifact/caddy" "./${PKG_DIR}/usr/bin/caddy"
    cp "./assets/caddy.service" "./${PKG_DIR}/etc/systemd/system/caddy.service"
    cp "./assets/Caddyfile" "./${PKG_DIR}/etc/caddy/Caddyfile"
    cp "./assets/scripts/postinst.sh" "./${PKG_DIR}/DEBIAN/postinst"
    cp "./assets/scripts/prerm.sh" "./${PKG_DIR}/DEBIAN/prerm"
    cp "./assets/scripts/postrm.sh" "./${PKG_DIR}/DEBIAN/postrm"

    echo "OK"
)}

function build_deb_package {(
    echo "Building DEB package..."
    cd ./pkg
    dpkg-deb --build $PKG_NAME
    mkdir -p "../result"
    cp "$PKG_NAME.deb" "../result"
    echo "OK"
)}

download_artifact
extract_files_from_artifact
copy_files_to_package_directory
build_deb_package
