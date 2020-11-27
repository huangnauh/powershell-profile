
# vscode
# Add-PathVariable "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\bin" 
$env:path += ";D:\software\SysinternalsSuite"
$env:path += ";D:\software\Command"
$Env:https_proxy = "http://127.0.0.1:7890"
# Import-Module oh-my-posh
Import-Module PSReadLine
Import-Module git-aliases -DisableNameChecking
# Import-Module posh-git
# Import-Module Terminal-Icons

# Set-PSReadLineOption -EditMode Emacs

# # In Emacs mode - Tab acts like in bash, but the Windows style completion
# # is still useful sometimes, so bind some keys so we can do both
# Set-PSReadLineKeyHandler -Key Ctrl+q -Function TabCompleteNext
# Set-PSReadLineKeyHandler -Key Ctrl+Q -Function TabCompletePrevious

# # Clipboard interaction is bound by default in Windows mode, but not Emacs mode.
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
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key Ctrl+q -Function TabCompleteNext
Set-PSReadlineKeyHandler -Key Ctrl+Shift+q -Function TabCompletePrevious
# The built-in word movement uses character delimiters, but token based word
# movement is also very useful - these are the bindings you'd use if you
# prefer the token based movements bound to the normal emacs word movement
# key bindings.
Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord
Set-PSReadLineKeyHandler -Key Ctrl+j -Function SelectShellBackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+k -Function SelectShellForwardWord
Set-PSReadLineKeyHandler -Key Alt+u -Function BackwardKillLine
Set-PSReadLineKeyHandler -Key Alt+w -Function BackwardKillWord



# # From https://serverfault.com/questions/95431/in-a-powershell-script-how-can-i-check-if-im-running-with-administrator-privil#97599
# function Test-Administrator  {  
# 	$user = [Security.Principal.WindowsIdentity]::GetCurrent();
# 	(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
# }

$profileDir = $PSScriptRoot;

foreach ( $includeFile in ("Get-Hash", "New-RandomPassword", "ForEach-Parallel", "ConvertFrom-UnixDate", "ConvertTo-UnixDate", "ConvertFrom-Base64", "ConvertTo-Base64") ) {
    # Unblock-File "$profileDir\Scripts\$includeFile.ps1"
    . "$profileDir\Scripts\$includeFile.ps1"
}


Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

Set-PsFzfOption -TabExpansion
# Set-PoshPrompt -Theme paradox

# $GitPromptSettings.EnableFileStatus = $false;
# Import-Module ZLocation
# Update-TypeData "$profileDir\My.Types.Ps1xml"

function GoBack { Set-Location .. }

Set-Alias vi vim
Set-Alias open Invoke-Item
Set-Alias .. GoBack

function Get-Path {
    ($Env:Path).Split(";")
}

Remove-Alias -Name ls
function ls($target) {
    Get-ChildItem $target | Format-Wide
}

Set-Alias ll Get-ChildItem

Set-Alias ctud  ConvertTo-UnixDate
Set-Alias cfud  ConvertFrom-UnixDate

Remove-Alias -Name cat
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


# From https://stackoverflow.com/questions/894430/creating-hard-and-soft-links-using-powershell
function ln($target, $link) {
    New-Item -ItemType SymbolicLink -Path $link -Value $target
}

set-alias new-link ln

function which($name) {
    Get-Command $name | Select-Object -ExpandProperty Definition
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


$grimoire = "ansible", "ansible-playbook"
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
$commands = "upssh", "tmux"

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
Register-ArgumentCompleter -CommandName $commands -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    # Map the command to the appropriate bash completion function.
    $F = switch ($commandAst.CommandElements[0].Value) {
        { $_ -in "awk", "grep", "head", "less", "ls", "sed", "seq", "tail" } {
            "_longopt"
            break
        }

        "man" {
            "_man"
            break
        }

        "upssh" {
            "_upssh"
            break
        }

        Default {
            "_minimal"
            break
        }
    }

    # Populate bash programmable completion variables.
    $COMP_LINE = "`"$commandAst`""
    $COMP_WORDS = "('$($commandAst.CommandElements.Extent.Text -join "' '")')" -replace "''", "'"
    for ($i = 1; $i -lt $commandAst.CommandElements.Count; $i++) {
        $extent = $commandAst.CommandElements[$i].Extent
        if ($cursorPosition -lt $extent.EndColumnNumber) {
            # The cursor is in the middle of a word to complete.
            $previousWord = $commandAst.CommandElements[$i - 1].Extent.Text
            $COMP_CWORD = $i
            break
        } elseif ($cursorPosition -eq $extent.EndColumnNumber) {
            # The cursor is immediately after the current word.
            $previousWord = $extent.Text
            $COMP_CWORD = $i + 1
            break
        } elseif ($cursorPosition -lt $extent.StartColumnNumber) {
            # The cursor is within whitespace between the previous and current words.
            $previousWord = $commandAst.CommandElements[$i - 1].Extent.Text
            $COMP_CWORD = $i
            break
        } elseif ($i -eq $commandAst.CommandElements.Count - 1 -and $cursorPosition -gt $extent.EndColumnNumber) {
            # The cursor is within whitespace at the end of the line.
            $previousWord = $extent.Text
            $COMP_CWORD = $i + 1
            break
        }
    }

    # Repopulate bash programmable completion variables for scenarios like '/mnt/c/Program Files'/<TAB> where <TAB> should continue completing the quoted path.
    $currentExtent = $commandAst.CommandElements[$COMP_CWORD].Extent
    $previousExtent = $commandAst.CommandElements[$COMP_CWORD - 1].Extent
    if ($currentExtent.Text -like "/*" -and $currentExtent.StartColumnNumber -eq $previousExtent.EndColumnNumber) {
        $COMP_LINE = $COMP_LINE -replace "$($previousExtent.Text)$($currentExtent.Text)", $wordToComplete
        $COMP_WORDS = $COMP_WORDS -replace "$($previousExtent.Text) '$($currentExtent.Text)'", $wordToComplete
        $previousWord = $commandAst.CommandElements[$COMP_CWORD - 2].Extent.Text
        $COMP_CWORD -= 1
    }

    # Build the command to pass to WSL.
    $command = $commandAst.CommandElements[0].Value
    $bashCompletion = ". /usr/share/bash-completion/bash_completion 2> /dev/null"
    $commandCompletion = ". /usr/share/bash-completion/completions/$command 2> /dev/null"
    $COMPINPUT = "COMP_LINE=$COMP_LINE; COMP_WORDS=$COMP_WORDS; COMP_CWORD=$COMP_CWORD; COMP_POINT=$cursorPosition"
    $COMPGEN = "bind `"set completion-ignore-case on`" 2> /dev/null; $F `"$command`" `"$wordToComplete`" `"$previousWord`" 2> /dev/null"
    $COMPREPLY = "IFS=`$'\n'; echo `"`${COMPREPLY[*]}`""
    $commandLine = "$bashCompletion; $commandCompletion; $COMPINPUT; $COMPGEN; $COMPREPLY" -split ' '

    # Invoke bash completion and return CompletionResults.
    $previousCompletionText = ""
    (wsl.exe $commandLine) -split '\n' |
    Sort-Object -Unique -CaseSensitive |
    ForEach-Object {
        if ($wordToComplete -match "(.*=).*") {
            $completionText = Format-WslArgument ($Matches[1] + $_) $true
            $listItemText = $_
        } else {
            $completionText = Format-WslArgument $_ $true
            $listItemText = $completionText
        }

        if ($completionText -eq $previousCompletionText) {
            # Differentiate completions that differ only by case otherwise PowerShell will view them as duplicate.
            $listItemText += ' '
        }

        $previousCompletionText = $completionText
        [System.Management.Automation.CompletionResult]::new($completionText, $listItemText, 'ParameterName', $completionText)
    }
}

# Helper function to escape characters in arguments passed to WSL that would otherwise be misinterpreted.
function global:Format-WslArgument([string]$arg, [bool]$interactive) {
    if ($interactive -and $arg.Contains(" ")) {
        return "'$arg'"
    } else {
        return ($arg -replace " ", "\ ") -replace "([()|])", ('\$1', '`$1')[$interactive]
    }
}

$ENV:STARSHIP_CACHE = "${env:TEMP}\starship"

Invoke-Expression (&starship init powershell)

Invoke-Expression (& {
        $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
        (zoxide init --hook $hook powershell) -join "`n"
    })

Invoke-Expression (@(gh completion -s powershell) -replace " ''\)$", " ' ')" -join "`n")
Invoke-Expression (@(kaf completion powershell) -replace " ''\)$", " ' ')" -join "`n")
