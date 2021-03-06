function Disable-CommandCoverage
{
    <#
    .Synopsis
        Disables command coverage for a module
    .Description
        Disables command coverage tracing for a module
    #>
    param(
    # The name of the module that will be instrumented for command coverage
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
    [Alias('Name')]
    [string]
    $Module
    )

    process {
        $moduleCommands = Get-Command -Module $module -commandType Function | ForEach-Object { $_.Name } 
        Get-PSBreakpoint -Command $moduleCommands | 
            Remove-PSBreakpoint
        $Global:CommandCoverage = $null
    }
} 
