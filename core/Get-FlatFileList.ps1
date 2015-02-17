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

function Get-FlatFileList {

 <#
    .SYNOPSIS
    Gets a flat file list from an array of files and directories.

    .DESCRIPTION
    It returns a list of files (as returned by Get-ChildItem) with additional 'RelativePath' property using following algorithm:
    a) for each file provided in 'Path', add this file with RelativePath = name of the file (without directory)
    b) for each directory $dir provided in 'Path', add each file from the directory with RelativePath = $dir.

    .PARAMETER Path
    List of directories / files.

    .PARAMETER Exclude
    Exclude mask.

    .EXAMPLE
    Get-FlatFileList -Path 'c:\dir1', 'c:\dir2\file1'    
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]
        $Path,

        [Parameter(Mandatory=$false)]
        [string[]]
        $Exclude
    ) 

    $result = New-Object System.Collections.ArrayList
    foreach ($p in $Path) {
        if (!(Test-Path -Path $p)) {
            # this function can be run remotely without PSCI available
            if (Get-Command -Name Write-Log -ErrorAction SilentlyContinue) {
                Write-Log -Critical "Path '$p' does not exist."
            } else {
                throw "Path '$p' does not exist"
            }
        } elseif (Test-Path -Path $p -PathType Container) {
            try {
                Push-Location -Path $p
                $files = Get-ChildItem -Path '.' -Recurse -Exclude $Exclude -File
                foreach ($file in $files) {
                    $relativePath = Resolve-Path -Path $file.FullName -Relative
                    if ($relativePath.StartsWith(".\")) {
                       $relativePath = $relativePath.Remove(0,2);
                    }
                    Add-Member -InputObject $file -MemberType NoteProperty -Name RelativePath -Value $relativePath
                    [void]($result.Add($file))
                }
            } finally {
                Pop-Location
            }
        } else {
            $files = Get-Item -Path $p -Exclude $Exclude
            foreach ($file in $files) {
                [void]($result.Add($file))
                Add-Member -InputObject $file -MemberType NoteProperty -Name RelativePath -Value $file.Name
            }
        }
    }
    return $result.ToArray()
}
