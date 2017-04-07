# condo

> A build system for \<any\> project.

## Vitals

Info          | Badges
--------------|--------------
Version       | [![Version][release-v-image]][release-url]
License       | [![License][license-image]][license]
Build Status  | [![Travis Build Status][travis-image]][travis-url] [![AppVeyor Build Status][appveyor-image]][appveyor-url]
Chat          | [![Join Chat][gitter-image]][gitter-url]
Issues        | [![Ready][issues-ready-image]][issues-url] [![In Progress][issues-inprogress-image]][issues-url]

## Getting Started

### What is Condo?

Condo is a cross-platform command line interface (CLI) build system for projects using NodeJS, CoreCLR, .NET Framework, or... well, anything.
It is capable of automatically detecting and executing all of the steps necessary to make <any> project function correctly, including, but not limited to:

* Automatic semantic versioning
* Restoring package manager dependencies (NuGet, NPM, Bower)
* Executing default task runner commands (Grunt, Gulp)
* Compiling projects and test projects (package.json and msbuild)
* Executing unit tests (xunit, mocha, jasmine, karma, protractor)
* Packing NuGet packages
* Pushing (Publishing) NuGet packages

These are just some of the most-used features of the build system.

### Installing Condo

Use the following to install condo on your local system:

#### macOS and Linux

```bash
curl -fsSL https://git.io/am-condo | /usr/bin/env bash
```

#### Windows

```posh
```

### Adding Condo to a Project

Initialize condo in a new project using the following steps:

1. Execute `condo-init`:

   ```
   dotnet condo init
   ```

2. Edit the `condo.build` to include your project and company info, for example:

    ```
    <?xml version="1.0" encoding="utf-8"?>
    <Project ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003"
            InitialTargets="Clean" DefaultTargets="Build">
        <PropertyGroup>
            <Product><!--AM.Condo--></Product>
            <StartDateUtc><!--2017-03-15--></StartDateUtc>

            <Company><!--automotiveMastermind--></Company>
            <Authors><!--automotiveMastermind--></Authors>

            <License><!--MIT--></License>
            <LicenseUri><!--https://opensource.org/licenses/MIT--></LicenseUri>
        </PropertyGroup>

        <Import Project="$(CondoTargetsPath)\Lifecycle.targets" />
        <Import Project="$(CondoTargetsPath)\Goals.targets" />
    </Project>
    ```

## Using Condo

### Executing Condo Locally

To execute condo locally, or on a build agent where condo is already installed and cached, use the `condo-target`
command, for example:

```
dotnet condo build
```

```
dotnet condo test
```

```
dotnet condo <TARGET>
```

### Executing Condo on a Build Agent

Use one of the following bootstrap scripts that were added to the root of your project by `condo-init`:

#### macOS and Linux

```bash
./condo.sh
```

#### Windows

```posh
.\condo.ps1
```

NOTE: The bootstrap scripts will automatically install and/or update condo and then execute the publish target.
Basically, it is a shorthand script for executing the following commands:

```
dotnet condo update
dotnet condo publish
```

If you would prefer to execute a different target, you can do so as follows:

#### macOS and Linux

```bash
./condo.sh <TARGET> <MSBUILD_OPTIONS>
```

#### Windows

```posh
.\condo.ps1 <TARGET> <MSBUILD_OPTIONS>
```

For example:

```bash
./condo.sh test -p:purpose=unit     # you may use either the hyphen or forward slash syntax on macOS and Linux
```

```posh
.\condo.ps1 test /p:purpose=unit    # you MUST use the forward slash syntax on Windows
```

## Documentation

NOTE: THE DOCUMENTATION IS CURRENTLY OUT OF DATE. THIS IS THE NEXT PRIORITY FOR THE CONDO TEAM. WE APOLOGIZE FOR THE
INCONVENIENCE!

For more information, please refer to the [official documentation][docs-url].

## Copright and License

&copy; automotiveMastermind and contributors. Distributed under the MIT license. See [LICENSE][] and [CREDITS][] for details.

[license-image]: https://img.shields.io/badge/license-MIT-blue.svg
[license]: LICENSE
[credits]: CREDITS

[release-url]: //github.com/automotivemastermind/condo/releases/latest
[release-v-image]:https://img.shields.io/github/release/automotivemastermind/condo.svg?style=flat-square&label=github

[travis-url]: //travis-ci.org/automotiveMastermind/condo
[travis-image]: https://img.shields.io/travis/automotiveMastermind/condo/develop.svg?label=travis

[appveyor-url]: //ci.appveyor.com/project/automotiveMastermind/condo
[appveyor-image]: https://img.shields.io/appveyor/ci/automotiveMastermind/condo/develop.svg?label=appveyor

[docs-url]: //automotivemastermind.github.io/condo

[gitter-url]: //gitter.im/automotivemastermind/condo
[gitter-image]:https://img.shields.io/badge/⊪%20gitter-join%20chat%20→-1dce73.svg

[issues-url]: //waffle.io/automotiveMastermind/condo
[issues-ready-image]: https://badge.waffle.io/automotivemastermind/condo.svg?label=ready&title=Ready
[issues-inprogress-image]: https://badge.waffle.io/automotivemastermind/condo.svg?label=in%20progress&title=In%20Progress
