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

<#
This file contains tokens, i.e. variables that can be different across environments or nodes.
Resolved $Tokens variable is available in configurations (DSC and functions).
Tokens are inherited from parent environments, so e.g. all Tokens defined in 'Default' environment (default parent of all environments) are available in 'Local' environment,
and child tokens can override parent tokens.

If token value is a string, you can use placeholders ${TokenName} where TokenName is another token name, or predefined 'Node' (destination node name).
If token value is a scriptblock, you can use variables $Tokens, $Node and $Environment.
#>

Environment Default {
    Tokens TestCategory @{
        Directory = 'c:\test1'
	}
}

Environment SecondEnv {
    Tokens TestCategory @{
        Directory = 'c:\test2'
	}
}

