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

function New-CopySessions {

    <#
	.SYNOPSIS
		Creates new PS sessions if they are needed (depending on hashes). Helper function for Copy-FilesToRemoteServer.

	.PARAMETER Path
		The file or directory path that should be sent to remote server.

    .PARAMETER ConnectionParams
        Connection parameters created by New-ConnectionParameters function.

	.PARAMETER Destination
		The remote path where the file will be saved to.
        
    .PARAMETER Exclude
        The files to be excluded from copying to remote server.

    .PARAMETER CheckHashMode
        There are three modes for checking whether the destination path needs to be updated:
        DontCheckHash - files are always uploaded to the servers
        AlwaysCalculateHash - files are uploaded to the servers if their hashes calculated in local path and in remote path are different
        UseHashFile - files are uploaded to the servers if there doesn't exist a syncHash_<hash> file, where hash is hash calculated in local path

    .PARAMETER HashPath
        Hash calculated for $Path. Used when CheckHashMode != DontCheckHash.

	.EXAMPLE			
        $sessions = New-CopySessions -Path $Path -ConnectionParams $ConnectionParams -Exclude $Exclude -Destination $Destination -CheckHashMode $CheckHashMode

	#>
    
    [CmdletBinding()]
	[OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]
        $Path,

        [Parameter(Mandatory = $true)]
        [object]
        $ConnectionParams,

        [Parameter(Mandatory = $false)]
        [string[]]
        $Destination,

        [Parameter(Mandatory = $false)]
        [string[]]
        $Exclude,

        [Parameter(Mandatory = $false)]
        [string]
        [ValidateSet('DontCheckHash','AlwaysCalculateHash','UseHashFile')]
        $CheckHashMode = 'DontCheckHash',

        [Parameter(Mandatory = $false)]
        [string]
        $HashPath
    )

    $sessions = @()
    # compare it with the hash of items on remote hosts
    foreach ($server in $ConnectionParams.Nodes) { 
        # Initialize session with remote server
        
        $psSessionParams = $ConnectionParams.PSSessionParams.Clone()
        $psSessionParams.ComputerName = $server
        $session = New-PsSession @psSessionParams

        $needUpdate = $true
        if ($CheckHashMode -eq 'AlwaysCalculateHash') {
            Invoke-Command -Session $session -ScriptBlock (Convert-FunctionToScriptBlock -FunctionName Get-FlatFileList)
            Invoke-Command -Session $session -ScriptBlock (Convert-FunctionToScriptBlock -FunctionName Get-Hash)
            $remoteHash = Invoke-Command -Session $session -ScriptBlock {
                $destinations = $using:Destination
                foreach ($dest in $destinations) {
                    if (!(Test-Path -Path $dest)) {
                        return $null
                    }
                }
                Get-Hash -Path $destinations -Exclude $using:Exclude
            }
            $needUpdate = $remoteHash -ne $HashPath
        } elseif ($CheckHashMode -eq 'UseHashFile' -and $HashPath) {
            $hashRemoteFilePath = Join-Path -Path $Destination[0] -ChildPath "syncHash_$HashPath"
            $hashFileExistsRemotely = Invoke-Command -Session $session -ScriptBlock {
                Test-Path -Path $using:hashRemoteFilePath
            }
            $needUpdate = !$hashFileExistsRemotely
        }

        if ($needUpdate) {
            # SuppressScriptCop - adding small arrays is ok
            $sessions += @($session)
        } else {
            Write-Log -Info "'$server' is up to date - no need to copy."
            Remove-PSSession -Session $session
        }
    }

    return $sessions
}
