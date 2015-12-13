---
layout: docs
title: mocha-download
group: shades
---

@{/*

mocha-download
    Downloads and installs mocha if it is not already installed.

mocha_download_path='$(base_path)'
    The path in which to download mocha.

base_path='$(CurrentDirectory)'
    The base path in which to download mocha.

*/}

use import = 'Condo.Build'

default base_path               = '${ Directory.GetCurrentDirectory() }'

default mocha_download_path     = '${ base_path }'

@{
    Build.Log.Header("mocha-download");

    var mocha_install               = Path.Combine(mocha_download_path, "node_modules", "mocha", "bin", "mocha");

    var mocha_locally_installed     = File.Exists(mocha_install);
    var mocha_version               = string.Empty;
    var mocha_globally_installed    = !mocha_locally_installed && Build.TryExecute("mocha", out mocha_version, "--version --config.interactive=false");
    var mocha_installed             = mocha_locally_installed || mocha_globally_installed;

    mocha_install = mocha_globally_installed ? "mocha" : mocha_install;

    Build.Log.Argument("path", mocha_install);

    if (mocha_globally_installed)
    {
        Build.Log.Argument("version", mocha_version);
    }

    Build.Log.Header();
}

npm-install npm_install_id='mocha' npm_install_prefix='${ mocha_download_path }' if='!mocha_installed'

- Build.SetPath("mocha", mocha_install, mocha_globally_installed);