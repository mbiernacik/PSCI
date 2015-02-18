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

function Build-DeploymentScriptsPackage {
    <#
    .SYNOPSIS
    Builds a package containing PSCI library and deployment configuration.

    .DESCRIPTION
    It copies the following to the destination package:
    - PSCI library to $OutputPathPsci - by default only core functions, PSCI.deploy module and DSC modules that are used in configuration files will be copied.
      If you need additional modules or external libraries, use $ModulesToInclude or $ExternalLibsToInclude parameters.
    - deploy.ps1 from current directory to $OutputPathDeploymentScripts
    - project configuration files (tokens / server roles) from $DeployConfigurationPath to $OutputPathDeploymentScripts\configuration.
    These files are required for any deployment that is to be run by PSCI.

    If $DeployConfigurationPath is not provided, it will be set to <current dir>\configuration.
    If $OutputPathPsci is not provided, it will be set to $PackagesPath\PSCI.
    If $OutputPathDeploymentScripts is not provided, it will be set to $PackagesPath\DeployScripts.
    
    .PARAMETER DeployConfigurationPath
    Path to the directory where configuration files reside, relative to $ProjectRootPath. By default '<script directory>\configuration'.

    .PARAMETER ReplaceDeployScriptParameters
    If true, default variable values (paths) in deploy.ps1 file will be updated to reflect the default package directory structure.

    .PARAMETER OutputPathPsci
    Output path where the PSCI package will be created. If not provided, $OutputPath = $PackagesPath\PSCI, where $PackagesPath is taken from global variable.

    .PARAMETER OutputPathDeploymentScripts
    Output path where project configuration package will be created. If not provided, $OutputPath = $PackagesPath\DeokiyScripts, where $PackagesPath is taken from global variable.

    .PARAMETER ModulesToInclude
    List of PSCI modules to include. If empty, only 'PSCI.deploy' module will be included.

    .PARAMETER ExternalLibsToInclude
    List of external libraries from to include (will be copied from 'externalLibs' folder).

    .EXAMPLE
    Build-DeploymentScriptsPackage

    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory=$false)]
        [string]
        $DeployConfigurationPath,

        [Parameter(Mandatory=$false)]
        [switch]
        $ReplaceDeployScriptParameters = $true,

        [Parameter(Mandatory=$false)]
        [string]
        $OutputPathPsci,

        [Parameter(Mandatory=$false)]
        [string]
        $OutputPathDeploymentScripts,

        [Parameter(Mandatory=$false)]
        [string[]]
        $ModulesToInclude,

        [Parameter(Mandatory=$false)]
        [string[]]
        $ExternalLibsToInclude

    )

    $configPaths = Get-ConfigurationPaths

    $deployScriptsPath = (Get-Location).Path
    if (!(Test-Path -Path 'deploy.ps1')) {
        Write-Log -Critical "deploy.ps1 has not been found at '$deployScriptsPath'. Please ensure you open the directory with deploy.ps1 before invoking Build-DeploymentScriptsPackage function."
    }
    
    $DeployConfigurationPath = Resolve-PathRelativeToProjectRoot `
                            -Path $DeployConfigurationPath `
                            -DefaultPath (Join-Path -Path $deployScriptsPath -ChildPath 'configuration') `
                            -CheckExistence:$true `
                            -ErrorMsg "DeployConfigurationPath '{0}' does not exist."
    
    $OutputPathPsci = Resolve-PathRelativeToProjectRoot `
                            -Path $OutputPathPsci `
                            -DefaultPath (Join-Path -Path $configPaths.PackagesPath -ChildPath "PSCI") `
                            -CheckExistence:$false

    $OutputPathDeploymentScripts = Resolve-PathRelativeToProjectRoot `
                            -Path $OutputPathDeploymentScripts `
                            -DefaultPath (Join-Path -Path $configPaths.PackagesPath -ChildPath "DeployScripts") `
                            -CheckExistence:$false

    
    Copy-PSCI -DeployConfigurationPath $DeployConfigurationPath `
              -OutputPathPsci $OutputPathPsci `
              -ModulesToInclude $ModulesToInclude `
              -ExternalLibsToInclude $ExternalLibsToInclude


    Copy-DeploymentScripts -DeployScriptsPath $deployScriptsPath `
                           -DeployConfigurationPath $DeployConfigurationPath `
                           -OutputDeployScriptsPath $OutputPathDeploymentScripts `
                           -OutputDeployConfigurationPath "$OutputPathDeploymentScripts\configuration"


    if ($ReplaceDeployScriptParameters) {
        Set-PackageDeployScriptParameters -DeployScriptToUpdatePath (Join-Path -Path $OutputPathDeploymentScripts -ChildPath 'deploy.ps1')
    }
   
}