<#
The MIT License (MIT)

Copyright (c) 2015 Objectivity Bespoke Software Specialists

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

function Invoke-MsBuild {
    <#
	.SYNOPSIS
	Invokes msbuild to build the specified project, using given version of msbuild (or the latest one if not specified).

    .PARAMETER ProjectPath
    Path to the project to build.

    .PARAMETER MsBuildOptions
    An object created by New-MsBuildOptions function, which specifies msbuild options.
    If not provided, default msbuild options will be used.

    .EXAMPLE
    Invoke-MsBuild -ProjectPath $projectPath -MsBuildOptions $MsBuildOptions
    #>

    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $ProjectPath,

        [Parameter(Mandatory=$false)]
        [PSObject]
        $MsBuildOptions
    )

    Write-ProgressExternal -Message 'Running msbuild' -ErrorMessage 'Msbuild error'

    # Take default MsBuildOptions if not provided
    if (!$MsBuildOptions) {
        $MsBuildOptions = New-MsBuildOptions
    }

    $ProjectPath = Resolve-PathRelativeToProjectRoot -Path $ProjectPath
                        
    $Targets = $MsBuildOptions.Targets
    $Configuration = $MsBuildOptions.Configuration
    $MsBuildProperties = $MsBuildOptions.MsBuildProperties
    $VisualStudioVersion = $MsBuildOptions.VisualStudioVersion
    $MsBuildVersion = $MsBuildOptions.MsBuildVersion
    $MsBuildForceArchitecture = $MsBuildOptions.MsBuildForceArchitecture

    $msbuildPath = Get-MsBuildPath -VisualStudioVersion $VisualStudioVersion -MsBuildVersion $MsBuildVersion -ForceArchitecture $MsBuildForceArchitecture
    if (!$msbuildPath) {
        if (!$MsBuildForceArchitecture) {
            $MsBuildForceArchitecture = "(default)"
        }
        if (!$VisualStudioVersion -and !$MsBuildVersion) {
            Write-Log -Critical "Cannot find any version of msbuild."
        }
        if ($VisualStudioVersion) {
            Write-Log -Critical "Cannot find msbuild for Visual Studio Version = '$VisualStudioVersion', architecture = '$MsBuildForceArchitecture'."
        }
        Write-Log -Critical "Cannot find msbuild version = '$MsBuildVersion', architecture = '$MsBuildForceArchitecture'."
    }

    $cmd = Add-QuotesToPaths -Paths $msbuildPath
    $cmd += " " + (Add-QuotesToPaths -Paths $ProjectPath)
    foreach ($target in $Targets) {
        $cmd += " /t:`"$target`""
    }
    if ($Configuration) {
        $cmd += " /p:Configuration=`"$Configuration`""
    }
    if ($MsBuildProperties) {
        foreach ($property in $MsBuildProperties.GetEnumerator()) {
            $cmd += (" /p:{0}=`"{1}`"" -f ($property.Key), ($property.Value))
        }
    }

    if ($VisualStudioVersion) {
        $vsVersionMap = @{ `
            "2010" = "10.0"; `
            "2012" = "11.0"; `
            "2013" = "12.0";
        }
        $vsVersion = $vsVersionMap[$VisualStudioVersion]
        $cmd += " /p:VisualStudioVersion=`"${vsVersion}`""
    }

    # maxcpucount - use all available cpus
    # nodeReuse - kill msbuild.exe process after finishing (without it issues with directory locking can occur)
    $cmd += " /nologo /maxcpucount /nodeReuse:false"

    # note: don't put [void] / Out-Null here as we need to write output
    Invoke-ExternalCommand -Command $cmd -DontCatchOutputStreams -ReturnLastExitCode:$false

    Write-ProgressExternal -Message '' -ErrorMessage ''
}