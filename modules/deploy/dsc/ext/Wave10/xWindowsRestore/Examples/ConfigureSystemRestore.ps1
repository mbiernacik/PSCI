﻿#--------------------------------------------------------------------------------- 

Configuration ConfigureSystemRestore
{
   Param
   (
       [String[]]$NodeName = $env:COMPUTERNAME
   )

    Import-DSCResource -ModuleName xWindowsRestore

    Node $NodeName
    {
        xSystemRestore SystemRestoreExample
        {
            Ensure = "Present"
            Drive = "C:\"
        }
    }
}

ConfigureSystemRestore -NodeName "localhost"
Start-DscConfiguration -Path .\ConfigureSystemRestore  -Wait -Force -Verbose