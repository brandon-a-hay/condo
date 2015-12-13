---
layout: docs
title: dnu-pack
group: shades
---

@{/*

dnu-pack
    Executes a dnu package manager command to pack all available projects.

dnu_pack_path='$(working_path)'
    Required. The path in which to execute the dnu command line tool.

dnu_pack_project=''
    A semi-colon (;) delimited list of projects to pack using the dnu command line tool.

dnu_pack_framework=''
    A semi-colon (;) delimited list of target frameworks to build against.

dnu_pack_configuration='$(configuration)'
    A semi-colon (;) delimited list of configurations to pack.

dnu_pack_options='' (Environment Variable: DNU_PACK_OPTIONS)
    Additional options to include when executing the dnu command line tool for pack operations.

dnu_pack_output_path='$(target_path)/build'
    The path in which to store the resulting packages (the name of the project will always be appended).

base_path='$(CurrentDirectory)'
    The base path in which to execute the dnu command line tool.

working_path='$(base_path)'
    The working path in which to execute the dnu command line tool.

target_path='$(working_path)/artifacts'
    The target path for build artifacts.

configuration=''
    The default configurations to use if no configurations are specified.

*/}

use namespace = 'System'
use namespace = 'System.IO'

use import = 'Condo.Build'

default configuration           = ''

default base_path               = '${ Directory.GetCurrentDirectory() }'
default working_path            = '${ base_path }'
default target_path             = '${ Path.Combine(base_path, "artifacts") }'

default dnu_pack_path           = '${ working_path }'
default dnu_pack_output_path    = '${ Path.Combine(target_path, "build") }'
default dnu_pack_project        = ''
default dnu_pack_framework      = ''
default dnu_pack_configuration  = '${ configuration }'
default dnu_pack_options        = '${ Build.Get("DNU_PACK_OPTIONS") }'

@{
    Build.Log.Header("dnu-pack");

    if (!string.IsNullOrEmpty(dnu_pack_project))
    {
        dnu_pack_project = dnu_pack_project.Trim();
    }

    if (!string.IsNullOrEmpty(dnu_pack_options))
    {
        dnu_pack_options = dnu_pack_options.Trim();
    }

    var dnu_pack_name = File.Exists(dnu_pack_path)
        ? Path.GetDirectoryName(dnu_pack_path)
        : Path.GetFileName(dnu_pack_path);

    dnu_pack_output_path = Path.Combine(dnu_pack_output_path, dnu_pack_name);

    Build.Log.Argument("path", dnu_pack_path);
    Build.Log.Argument("project", dnu_pack_project);
    Build.Log.Argument("framework", dnu_pack_framework);
    Build.Log.Argument("configuration", dnu_pack_configuration);
    Build.Log.Argument("options", dnu_pack_options);
    Build.Log.Argument("output path", dnu_pack_output_path);
    Build.Log.Header();

    dnu_pack_project = dnu_pack_project.Replace(';', ' ').Trim();

    if (!string.IsNullOrEmpty(dnu_pack_output_path))
    {
        dnu_pack_options += string.Format(@" --out ""{0}""", dnu_pack_output_path);
    }

    if (!string.IsNullOrEmpty(dnu_pack_framework))
    {
        dnu_pack_options += string.Format(@" --framework ""{0}""", dnu_pack_framework);
    }

    if (!string.IsNullOrEmpty(dnu_pack_configuration))
    {
        dnu_pack_options += string.Format(@" --configuration ""{0}""", dnu_pack_configuration);
    }

    dnu_pack_options = dnu_pack_options.Trim();
}

dnu dnu_args='pack ${ dnu_pack_project }' dnu_options='${ dnu_pack_options }' dnu_runtime='default -r ${ Build.Unix ? "mono" : "clr" }' dnu_path='${ dnu_pack_path }'