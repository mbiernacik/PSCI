function Test-ForCommonParameterMistake
{
    param(
    [Parameter(ParameterSetName='TestCommandInfo',Mandatory=$true,ValueFromPipeline=$true)]
    [Management.Automation.CommandInfo]
    $CommandInfo
    )
                
    begin {
        $commonSwitches = "AllowClobber",
            "AsJob",
            "Force", 
            "PassThru"
            
            
    }        
    
    process {        
        foreach ($switch in $commonSwitches) {
            $param = $command.Parameters.$switch 
            if ($param -and 
                $param.ParameterType -ne [switch]) {
                Write-Error "$CommandInfo parameter $switch should be a [switch] Parameter"
            }
        }
        
        if ($CommandInfo.Parameters.InputObject) {
            $inputObjectFromPipeline = $CommandInfo.Parameters.InputObject.Attributes | 
                Where-Object { $_.ValueFromPipeline -eq $true }
                
            if (-not $inputObjectFromPipeline) {                
                Write-Error "$commandInfo has an -InputObject parameter that is not a ValueFromPipeline parameter"                
            }
        }
        
        $param = $CommandInfo.Parameters.Credential 
        if ($param -and $param.ParameterType -ne [Management.Automation.PSCredential]) {
            Write-Error -Message "$commandInfo Credential parameter be a [Management.Automation.PSCredential] Parameter"            
        }
    }
}