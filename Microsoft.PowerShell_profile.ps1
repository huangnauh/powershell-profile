# vscode
# Add-PathVariable "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\bin"
#$env:path += ";D:\software\Command"
$env:IPFS_PATH = "D:\software\ipfs"
$env:COLI_CACHE = "D:\software\cache"
$env:YARR_OPENBROWSER = $True
#$env:https_proxy = "http://127.0.0.1:7890"
$env:STARSHIP_CACHE = "${env:TEMP}\starship"
# Import-Module oh-my-posh
Import-Module PSReadLine
# Import-Module posh-git
# Import-Module Terminal-Icons

# Set-PSReadLineOption -EditMode Emacs

# # In Emacs mode - Tab acts like in bash, but the Windows style completion
# # is still useful sometimes, so bind some keys so we can do both
# Set-PSReadLineKeyHandler -Key Ctrl+q -Function TabCompleteNext
# Set-PSReadLineKeyHandler -Key Ctrl+Q -Function TabCompletePrevious

# Clipboard interaction is bound by default in Windows mode, but not Emacs mode.
# Set-PSReadLineKeyHandler -Key Ctrl+C -Function Copy
# Set-PSReadLineKeyHandler -Key Ctrl+v -Function Paste

# Import-Module Get-ChildItemColor
# Advanced Autocompletion for arrow keys
Set-PSReadLineOption -MaximumHistoryCount 20000
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
# Change how powershell does tab completion
# http://stackoverflow.com/questions/39221953/can-i-make-powershell-tab-complete-show-me-all-options-rather-than-picking-a-sp
Set-PSReadlineKeyHandler -Key Ctrl+q -Function TabCompleteNext
Set-PSReadlineKeyHandler -Key Ctrl+Shift+q -Function TabCompletePrevious
# The built-in word movement uses character delimiters, but token based word
# movement is also very useful - these are the bindings you'd use if you
# prefer the token based movements bound to the normal emacs word movement
# key bindings.
Set-PSReadLineKeyHandler -Key Ctrl+y -Function Redo
Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord
Set-PSReadLineKeyHandler -Key Ctrl+j -Function SelectShellBackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+k -Function SelectShellForwardWord
Set-PSReadLineKeyHandler -Key Alt+u -Function BackwardKillLine
Set-PSReadLineKeyHandler -Key Alt+w -Function BackwardKillWord

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
#Set-PSReadLineKeyHandler -Chord Tab -ScriptBlock { Invoke-FzfTabCompletion }
#Set-PSReadlineKeyHandler -Chord "Ctrl+y" -ScriptBlock { Invoke-FuzzyHistory }
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PsFzfOption -TabExpansion


# From https://serverfault.com/questions/95431/in-a-powershell-script-how-can-i-check-if-im-running-with-administrator-privil#97599
function Test-Administrator  {
	$user = [Security.Principal.WindowsIdentity]::GetCurrent();
 	(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function scoop {
    if ($args[0] -eq "search") {
        scoop-search.exe @($args | Select-Object -Skip 1)
    } else {
        scoop.ps1 @args
    }
}

$profileDir = $PSScriptRoot;
$Scripts = ("Get-Hash", "ForEach-Parallel",
    "ConvertFrom-UnixDate", "ConvertTo-UnixDate", "ConvertFrom-Base64", "ConvertTo-Base64",
    "_lsd"
)

foreach ( $includeFile in $Scripts) {
    # Unblock-File "$profileDir\Scripts\$includeFile.ps1"
    . "$profileDir\Scripts\$includeFile.ps1"
}

Invoke-Expression (&starship init powershell)
Invoke-Expression (& {
        (zoxide init --hook pwd powershell) -join "`n"
    })

(& rustup completions powershell) | Out-String | Invoke-Expression
# (& kaf completion powershell) | Out-String | Invoke-Expression
# (& coli completion powershell) | Out-String | Invoke-Expression
# (& chezmoi completion powershell) | Out-String | Invoke-Expression
#(& gh completion -s powershell) | Out-String | Invoke-Expression
# Invoke-Expression (@(gh completion -s powershell) -replace " ''\)$", " ' ')" -join "`n")

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

$promptScript = (Get-Item function:prompt).ScriptBlock
function Prompt {
    $path = Get-Location
    $host.ui.RawUI.WindowTitle = $path
    & $promptScript
}

Import-Module git-aliases -DisableNameChecking

Set-Alias cde Set-LocationFuzzyEverything
Set-Alias fgst Invoke-FuzzyGitStatus

# Set-PoshPrompt -Theme paradox

# $GitPromptSettings.EnableFileStatus = $false;
# Import-Module ZLocation
# Update-TypeData "$profileDir\My.Types.Ps1xml"

function GoBack { Set-Location .. }

Set-Alias vi nvim
Set-Alias open Invoke-Item
Set-Alias .. GoBack

function Get-Path {
    ($Env:Path).Split(";")
}

# Remove-Alias -Name ls
function ls($target) {
    Get-ChildItem $target | Format-Wide Name -AutoSize
}

Set-Alias ll Get-ChildItem
Set-Alias l Get-ChildItem

Set-Alias ctud  ConvertTo-UnixDate
Set-Alias cfud  ConvertFrom-UnixDate

# Remove-Alias -Name cat
function cat($target) {
    bat -pp $target
}

function catl($target) {
    bat --style=grid $target
}

function Get-Process-For-Port($port) {
    Get-Process -Id (Get-NetTCPConnection -LocalPort $port).OwningProcess
}

function Get-Serial-Number {
    Get-CimInstance -ClassName Win32_Bios | select-object serialnumber
}

function New-UUID {
    [guid]::NewGuid().ToString()
}

# From https://stackoverflow.com/questions/894430/creating-hard-and-soft-links-using-powershell
function ln($target, $link) {
    New-Item -ItemType SymbolicLink -Path $link -Value $target
}

set-alias new-link ln

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
}

function Set-Proxy {
    $proxy = 'http://127.0.0.1:7890'

    $env:HTTPS_PROXY = $proxy
}

function Get-Proxy {
    $env:HTTPS_PROXY
}

function Clear-Proxy {
    Remove-Item env:HTTPS_PROXY
}

function tr {
    if ($args.Length -eq 0 ) {
        Write-Output 'this is a cli translator, try `fy hello world`.'
    } else {
        $query = ""
        for ($i = 0; $i -lt $args.Count; $i++) {
            $query += " "
            $query += $args[$i]
        }

        $ApiUrl = "http://fanyi.youdao.com/openapi.do?keyfrom=CapsLock&key=12763084&type=data&doctype=json&version=1.1&q={0}" -f $query

        $info = (Invoke-WebRequest $ApiUrl).Content | ConvertFrom-Json

        Write-Host "@" $query  "[" $info.basic.phonetic "]"
        Write-Host "翻译：`t" $info.translation
        Write-Host "词典："
        for ($i = 0; $i -lt $info.basic.explains.Count; $i++) {
            Write-Host "`t" $info.basic.explains[$i]
        }
        Write-Host "网络："
        for ($i = 0; $i -lt $info.web.Count; $i++) {
            Write-Host "`t" $info.web[$i].key ": " -NoNewline
            for ($j = 0; $j -lt $info.web[$i].value.Count; $j++) {
                Write-Host $info.web[$i].value[$j] "; " -NoNewline
            }
            Write-Host ""
        }
    }
}


function ssh-proxy {
    ssh -o ProxyCommand="connect.exe -S 127.0.0.1:7890 %h %p" $args
}

function df {
    Get-PSDrive -PSProvider FileSystem
}

function reboot {
    shutdown /r /t 0
}


# $grimoire = "ansible", "ansible-playbook"
$grimoire = @()
$grimoire | ForEach-Object { Invoke-Expression @"
function global:$_() {
    for (`$i = 0; `$i -lt `$args.Count; `$i++) {
        if (`$args[`$i].StartsWith('-')) {
            `$i++
        }
        `$args[`$i] = `"'`" + `$args[`$i] +  `"'`"
    }
    Write-Output "cd /home/huangnauh/grimoire && $_ `$args"
    wsl.exe bash -ic "cd /home/huangnauh/grimoire && $_ `$args"
}
"@
}

# https://devblogs.microsoft.com/commandline/integrate-linux-commands-into-windows-with-powershell-and-the-windows-subsystem-for-linux/
# The commands to import.
#$commands = "awk", "head", "man", "sed", "seq", "upssh", "tail", "tmux"
$commands = @()

# Register a function for each command.
$commands | ForEach-Object { Invoke-Expression @"
Remove-Alias $_ -Force -ErrorAction Ignore
function global:$_() {
    for (`$i = 0; `$i -lt `$args.Count; `$i++) {
        if (`$args[`$i].StartsWith('-')) {
            `$i++
        }
        if (`$i -ge `$args.Count) {
            break
        }
        # If a path is absolute with a qualifier (e.g. C:), run it through wslpath to map it to the appropriate mount point.
        if (Split-Path `$args[`$i] -IsAbsolute -ErrorAction Ignore) {
            `$args[`$i] = Format-WslArgument (wsl.exe bash -ic "wslpath '`$(`$args[`$i])'")
        # If a path is relative, the current working directory will be translated to an appropriate mount point, so just format it.
        } elseif (Test-Path `$args[`$i] -ErrorAction Ignore) {
            `$args[`$i] = Format-WslArgument (wsl.exe bash -ic "wslpath '`$(Resolve-Path `$args[`$i])'")
        }
        # `$args[`$i] = `"'`" + `$args[`$i] +  `"'`"
    }

    Write-Output "$_ `$args"
    if (`$input.MoveNext()) {
        `$input.Reset()
        `$input | wsl bash -ic "$_ `$args"
    } else {
        wsl bash -ic "$_ `$args"
    }
}
"@
}

# Register an ArgumentCompleter that shims bash's programmable completion.
# Register-ArgumentCompleter -CommandName $commands -ScriptBlock {
#     param($wordToComplete, $commandAst, $cursorPosition)

#     # Map the command to the appropriate bash completion function.
#     $F = switch ($commandAst.CommandElements[0].Value) {
#         { $_ -in "awk", "grep", "head", "less", "ls", "sed", "seq", "tail" } {
#             "_longopt"
#             break
#         }

#         "man" {
#             "_man"
#             break
#         }

#         "upssh" {
#             "_upssh"
#             break
#         }

#         Default {
#             "_minimal"
#             break
#         }
#     }

#     # Populate bash programmable completion variables.
#     $COMP_LINE = "`"$commandAst`""
#     $COMP_WORDS = "('$($commandAst.CommandElements.Extent.Text -join "' '")')" -replace "''", "'"
#     for ($i = 1; $i -lt $commandAst.CommandElements.Count; $i++) {
#         $extent = $commandAst.CommandElements[$i].Extent
#         if ($cursorPosition -lt $extent.EndColumnNumber) {
#             # The cursor is in the middle of a word to complete.
#             $previousWord = $commandAst.CommandElements[$i - 1].Extent.Text
#             $COMP_CWORD = $i
#             break
#         } elseif ($cursorPosition -eq $extent.EndColumnNumber) {
#             # The cursor is immediately after the current word.
#             $previousWord = $extent.Text
#             $COMP_CWORD = $i + 1
#             break
#         } elseif ($cursorPosition -lt $extent.StartColumnNumber) {
#             # The cursor is within whitespace between the previous and current words.
#             $previousWord = $commandAst.CommandElements[$i - 1].Extent.Text
#             $COMP_CWORD = $i
#             break
#         } elseif ($i -eq $commandAst.CommandElements.Count - 1 -and $cursorPosition -gt $extent.EndColumnNumber) {
#             # The cursor is within whitespace at the end of the line.
#             $previousWord = $extent.Text
#             $COMP_CWORD = $i + 1
#             break
#         }
#     }

#     # Repopulate bash programmable completion variables for scenarios like '/mnt/c/Program Files'/<TAB> where <TAB> should continue completing the quoted path.
#     $currentExtent = $commandAst.CommandElements[$COMP_CWORD].Extent
#     $previousExtent = $commandAst.CommandElements[$COMP_CWORD - 1].Extent
#     if ($currentExtent.Text -like "/*" -and $currentExtent.StartColumnNumber -eq $previousExtent.EndColumnNumber) {
#         $COMP_LINE = $COMP_LINE -replace "$($previousExtent.Text)$($currentExtent.Text)", $wordToComplete
#         $COMP_WORDS = $COMP_WORDS -replace "$($previousExtent.Text) '$($currentExtent.Text)'", $wordToComplete
#         $previousWord = $commandAst.CommandElements[$COMP_CWORD - 2].Extent.Text
#         $COMP_CWORD -= 1
#     }

#     # Build the command to pass to WSL.
#     $command = $commandAst.CommandElements[0].Value
#     $bashCompletion = ". /usr/share/bash-completion/bash_completion 2> /dev/null"
#     $commandCompletion = ". /usr/share/bash-completion/completions/$command 2> /dev/null"
#     $COMPINPUT = "COMP_LINE=$COMP_LINE; COMP_WORDS=$COMP_WORDS; COMP_CWORD=$COMP_CWORD; COMP_POINT=$cursorPosition"
#     $COMPGEN = "bind `"set completion-ignore-case on`" 2> /dev/null; $F `"$command`" `"$wordToComplete`" `"$previousWord`" 2> /dev/null"
#     $COMPREPLY = "IFS=`$'\n'; echo `"`${COMPREPLY[*]}`""
#     $commandLine = "$bashCompletion; $commandCompletion; $COMPINPUT; $COMPGEN; $COMPREPLY" -split ' '

#     # Invoke bash completion and return CompletionResults.
#     $previousCompletionText = ""
#     (wsl.exe $commandLine) -split '\n' |
#     Sort-Object -Unique -CaseSensitive |
#     ForEach-Object {
#         if ($wordToComplete -match "(.*=).*") {
#             $completionText = Format-WslArgument ($Matches[1] + $_) $true
#             $listItemText = $_
#         } else {
#             $completionText = Format-WslArgument $_ $true
#             $listItemText = $completionText
#         }

#         if ($completionText -eq $previousCompletionText) {
#             # Differentiate completions that differ only by case otherwise PowerShell will view them as duplicate.
#             $listItemText += ' '
#         }

#         $previousCompletionText = $completionText
#         [System.Management.Automation.CompletionResult]::new($completionText, $listItemText, 'ParameterName', $completionText)
#     }
# }

# Helper function to escape characters in arguments passed to WSL that would otherwise be misinterpreted.
function global:Format-WslArgument([string]$arg, [bool]$interactive) {
    if ($interactive -and $arg.Contains(" ")) {
        return "'$arg'"
    } else {
        return ($arg -replace " ", "\ ") -replace "([()|])", ('\$1', '`$1')[$interactive]
    }
}

    # Smart Quotes Insert/Delete
    # The next four key handlers are designed to make entering matched quotes
    # parens, and braces a nicer experience.  I'd like to include functions
    # in the module that do this, but this implementation still isn't as smart
    # as ReSharper, so I'm just providing it as a sample.
    # Set-PSReadLineKeyHandler -Key '"',"'" `
    #     -BriefDescription SmartInsertQuote `
    #     -LongDescription "Insert paired quotes if not already on a quote" `
    #     -ScriptBlock {
    #     param($key, $arg)

    #     $quote = $key.KeyChar

    #     $selectionStart = $null
    #     $selectionLength = $null
    #     [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState(`
    #         [ref]$selectionStart, [ref]$selectionLength)

    #     $line = $null
    #     $cursor = $null
    #     [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(`
    #         [ref]$line, [ref]$cursor)

    #     # If text is selected, just quote it without any smarts
    #     if ($selectionStart -ne -1) {
    #         [Microsoft.PowerShell.PSConsoleReadLine]::Replace(`
    #             $selectionStart, $selectionLength, $quote +
    #             $line.SubString($selectionStart, $selectionLength) + $quote)
    #         [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(`
    #             $selectionStart + $selectionLength + 2)
    #         return
    #     }

    #     $ast = $null
    #     $tokens = $null
    #     $parseErrors = $null
    #     [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(`
    #         [ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

    #     function FindToken {
    #         param($tokens, $cursor)

    #         foreach ($token in $tokens) {
    #             if ($cursor -lt $token.Extent.StartOffset) { continue }
    #             if ($cursor -lt $token.Extent.EndOffset) {
    #                 $result = $token
    #                 $token = $token -as [System.Management.Automation.Language.StringExpandableToken]
    #                 if ($token) {
    #                     $nested = FindToken $token.NestedTokens $cursor
    #                     if ($nested) { $result = $nested }
    #                 }

    #                 return $result
    #             }
    #         }
    #         return $null
    #     }

    #     $token = FindToken $tokens $cursor

    #     # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
    #     if ($token -is [System.Management.Automation.Language.StringToken] -and
    #         $token.Kind -ne [System.Management.Automation.Language.TokenKind]::Generic) {
    #         # If we're at the start of the string, assume we're inserting a new string
    #         if ($token.Extent.StartOffset -eq $cursor) {
    #             [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
    #             [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    #             return
    #         }

    #         # If we're at the end of the string, move over the closing quote if present.
    #         if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
    #             [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    #             return
    #         }
    #     }

    #     if ($null -eq $token -or
    #         $token.Kind -eq [System.Management.Automation.Language.TokenKind]::RParen -or
    #         $token.Kind -eq [System.Management.Automation.Language.TokenKind]::RCurly -or
    #         $token.Kind -eq [System.Management.Automation.Language.TokenKind]::RBracket) {
    #         if ($line[0..$cursor].Where{$_ -eq $quote}.Count % 2 -eq 1) {
    #             # Odd number of quotes before the cursor, insert a single quote
    #             [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
    #         } else {
    #             # Insert matching quotes, move cursor to be in between the quotes
    #             [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
    #             [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    #         }
    #         return
    #     }

    #     if ($token.Extent.StartOffset -eq $cursor) {
    #         if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Generic -or
    #             $token.Kind -eq [System.Management.Automation.Language.TokenKind]::Identifier -or
    #             $token.Kind -eq [System.Management.Automation.Language.TokenKind]::Variable -or
    #             $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
    #             $end = $token.Extent.EndOffset
    #             $len = $end - $cursor
    #             [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote +
    #                 $line.SubString($cursor, $len) + $quote)
    #             [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
    #             return
    #         }
    #     }

    #     # We failed to be smart, so just insert a single quote
    #     [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
    # }
