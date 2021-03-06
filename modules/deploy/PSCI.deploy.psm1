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


$curDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Get-ChildItem -Recurse $curDir -Include *.ps1 | Where-Object { $_ -notmatch ".Tests.ps1" -and $_ -notmatch "Import-DeploymentConfiguration.ps1" -and $_ -notmatch "\\dsc\\"} | Foreach-Object {
    . $_.FullName      
}


Export-ModuleMember -Function `
    Environment, `
    ServerRole, `
    Tokens, `
    Import-DeploymentConfiguration, `
    Start-Deployment, `
    New-MsDeployConfiguration, `
    Clear-DscCache, `
    Deploy-EntityFrameworkMigratePackage, `
    Deploy-MsDeployPackage, `
    Deploy-SSASPackage, `
    Deploy-SqlPackage, `
    Deploy-SqlServerAgentPackage, `
    Deploy-SSDTDacpac, `
    Deploy-SSISIspac, `
    Deploy-SSISPackage, `
    Deploy-SSRSModule, `
    Deploy-SSRSReportsByVisualStudio, `
    Deploy-SSRSReportsByWebService, `
    Install-DscResources, `
    Update-ConfigFile, `
    Update-TokensInAllFiles, `
    Update-TokensInZipFile, `
    Sync-MsDeployDirectory, `
    Get-SSRSProjectConfiguration, `
    New-EventLogSource, `
    New-SSRSDataSet, `
    New-SSRSDataSource, `
    New-SSRSDataSourceDefinition, `
    New-SSRSResource, `
    New-SSRSFolder, `
    New-SSRSWebServiceProxy, `
    Start-SqlServerAgentJob, `
    Write-DscErrorsFromEventLog

    