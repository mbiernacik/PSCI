function Test-ParameterNamingConvention
{
    param(
    [Parameter(ParameterSetName='TestCommandInfo',Mandatory=$true,ValueFromPipeline=$true)]
    [Management.Automation.CommandInfo]
    $CommandInfo
    )
        
    
    process {    
        $commandName = $commandInfo.Name
        $lowerCasedParameters = $commandInfo.parameters.keys -cmatch "^\p{Ll}"
        if ($lowerCasedParameters) { 
            $errInfo = @{
                Message = "Parameters should start with a capital letter.  $CommandInfo the following parameters start with a lowercase letter: $($lowerCasedParameters -join ',')"  
                TargetObject = $lowerCasedParameters
                ErrorId = "ParameterNamingConvetion.ParametersMustStartWithACapitalLetter"
            }
            Write-Error @errInfo
            
        }        
    }
} 
