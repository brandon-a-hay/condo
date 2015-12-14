---
layout: docs
title: dnx-test
group: shades
---

@{/*

dnx-test
    Executes unit tests for test projects.

dnx_test_args=''
    The arguments to pass to the test command.

dnx_test_options='' (Environment Variable: DNX_TEST_OPTIONS)
    Additional options to pass to the test command.

dnx_test_path='$(test_path)'
    The path in which to locate test projects.

dnx_test_output_path='$(target_path)/test'
    The path in which to store the test results.

dnx_test_coverage='$(Coverage)'
    A value indicating whether or not to perform code coverage analysis.

    NOTE: Performing code coverage is only supported on Windows at the present time.

base_path='$(CurrentDirectory)'
    The base path in which to locate test projects.

working_path='$(base_path)'
    The working path in which to execute unit tests.

target_path='$(working_path)/artifacts'
    The target path for build artifacts.

target_build_path='$(base_path)/build'
    The targt path in which to locate src projects.

target_test_path='$(base_path)/test'
    The path in which to locate test projects.

dnx_test_wait='true'
    A value indicating whether or not to wait for exit.

dnx_test_quiet='$(Build.Log.Quiet)'
    A value indicating whether or not to execute the command quietly.

*/}

use assembly = 'System.Web.Extensions, Version=3.5.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35'

use namespace = 'System'
use namespace = 'System.Web.Script.Serialization'

use import = 'Condo.Build'
use import = 'Files'

default Quiet                   = '${ false }'
default Coverage                = '${ false }'

default configuration           = 'Debug'

default base_path               = '${ Directory.GetCurrentDirectory() }'
default working_path            = '${ base_path }'
default test_path               = '${ Path.Combine(base_path, "test") }'
default target_path             = '${ Build.Get("BUILD_BINARIESDIRECTORY", Path.Combine(base_path, "artifacts")) }'
default target_build_path       = '${ Path.Combine(target_path, "build") }'
default target_test_path        = '${ Build.Get("COMMON_TESTRESULTSDIRECTORY", Path.Combine(target_path, "test")) }'

default dnx_test_args           = ''
default dnx_test_path           = '${ test_path }'
default dnx_test_options        = '${ Build.Get("DNX_TEST_OPTIONS") }'
default dnx_build_output_path   = '${ target_build_path }'
default dnx_test_output_path    = '${ target_test_path }'
default dnx_test_coverage       = '${ Coverage }'

@{
    Build.Log.Header("dnx-test");

    dnx_test_args = dnx_test_args.Trim();
    dnx_test_options = dnx_test_options.Trim();

    Build.Log.Argument("arguments", dnx_test_args);
    Build.Log.Argument("options", dnx_test_options);
    Build.Log.Argument("path", dnx_test_path);
    Build.Log.Argument("output path", dnx_test_output_path);
    Build.Log.Header();

    Build.MakeDirectory(dnx_test_output_path);

    var dnx_test_exclude = '**/bin/**/project.json';
    var dnx_test_include = '**/project.json';
    var dnx_test_folder = Path.GetFullPath(dnx_test_path);

    if (File.Exists(dnx_test_folder))
    {
        dnx_test_include = Path.GetFileName(dnx_test_folder);
        dnx_test_folder = Path.GetDirectoryName(dnx_test_folder);
    }

    var dnx_test_files = Files.BasePath(dnx_test_folder)
        .Include(dnx_test_include)
        .Exclude(dnx_test_exclude);

    var js = new JavaScriptSerializer();

    foreach (var dnx_test_file in dnx_test_files)
    {
        var dnx_test_file_path = Path.Combine(dnx_test_folder, dnx_test_file);
        var dnx_test_file_text = File.ReadAllText(dnx_test_file_path);
        var dnx_test_project = js.DeserializeObject(dnx_test_file_text) as Dictionary<string, object>;

        object dnx_test_cmds_obj;

        var dnx_test_cmds = dnx_test_project.TryGetValue("commands", out dnx_test_cmds_obj)
            ? dnx_test_cmds_obj as Dictionary<string, object>
            : new Dictionary<string, object>();

        object dnx_test_cmd_obj;

        if (!dnx_test_cmds.TryGetValue("test", out dnx_test_cmd_obj))
        {
            continue;
        }

        var dnx_test_cmd = dnx_test_cmd_obj as string;

        dnx_test_folder = Path.GetDirectoryName(dnx_test_file_path);
        var dnx_test_name = Path.GetFileName(dnx_test_folder);

        object dnx_test_cfgs_obj;

        var dnx_test_cfgs = dnx_test_project.TryGetValue("frameworks", out dnx_test_cfgs_obj)
            ? dnx_test_cfgs_obj as Dictionary<string, object>
            : new Dictionary<string, object> { { "dnx451", new Dictionary<string, object>() } };

        var dnx_test_frameworks = dnx_test_cfgs.Keys.Where(key => key.StartsWith("dnx", StringComparison.OrdinalIgnoreCase));

        foreach (var dnx_test_framework in dnx_test_frameworks)
        {
            var dnx_test_args_current = "test " + (dnx_test_args ?? "");
            var dnx_test_options_current = dnx_test_options ?? "";
            var dnx_test_coverage_output_file = Path.Combine(dnx_test_output_path, "coverage", dnx_test_name + "-" + dnx_test_framework + "-coverage.xml");
            var dnx_test_runtime = "default";

            if (dnx_test_framework.IndexOf("core", StringComparison.OrdinalIgnoreCase) > -1)
            {
                dnx_test_runtime += " -r coreclr";
            }
            else if (Build.Unix)
            {
                dnx_test_runtime += " -r mono";
            }
            else
            {
                dnx_test_runtime += " -r clr";
            }

            var dnx_coverage_pdb_path = string.Format
                (
                    @"""{0}"";""{1}""",
                    Path.Combine(dnx_build_output_path, dnx_test_name.Remove(dnx_test_name.LastIndexOf('.')), configuration, dnx_test_framework),
                    Path.Combine(dnx_test_output_path, dnx_test_name, configuration, dnx_test_framework)
                );

            // dnx_coverage_pdb_path = Path.Combine(dnx_test_output_path, dnx_test_name, configuration, dnx_test_framework);

            if (dnx_test_cmd.Contains("xunit"))
            {
                var dnx_test_output_file = Path.Combine(dnx_test_output_path, dnx_test_name + "-" + dnx_test_framework + ".xml");
                dnx_test_options_current += " -xml \"" + dnx_test_output_file + "\"";
            }

            ExecuteTests(dnx_test_args_current.Trim(), dnx_test_options_current.Trim(), dnx_test_folder, dnx_coverage_pdb_path, dnx_test_coverage_output_file, dnx_test_runtime, dnx_test_coverage, Quiet);
        }
    }
}

macro name='ExecuteTests' args='string' options='string' path='string' pdb='string' output='string' runtime='string' coverage='bool' Quiet='bool'
    dnx dnx_args='${ args }' dnx_options='${ options }' dnx_path='${ path }' dnx_runtime='${ runtime }' if='!coverage'
    dotnet-cover dotnet_cover_args='${ args } ${ options }' dotnet_cover_output_path='${ output }' dotnet_cover_path='${ path }' dotnet_cover_pdb_path='${ pdb }' dotnet_cover_dnx_runtime='${ runtime }' if='coverage'