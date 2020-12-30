
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName 'lsd' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'lsd'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-')) {
                break
        }
        $element.Value
    }) -join ';'

    $completions = @(switch ($command) {
        'lsd' {
            [CompletionResult]::new('--color', 'color', [CompletionResultType]::ParameterName, 'When to use terminal colours')
            [CompletionResult]::new('--icon', 'icon', [CompletionResultType]::ParameterName, 'When to print the icons')
            [CompletionResult]::new('--icon-theme', 'icon-theme', [CompletionResultType]::ParameterName, 'Whether to use fancy or unicode icons')
            [CompletionResult]::new('--depth', 'depth', [CompletionResultType]::ParameterName, 'Stop recursing into directories after reaching specified depth')
            [CompletionResult]::new('--size', 'size', [CompletionResultType]::ParameterName, 'How to display size')
            [CompletionResult]::new('--date', 'date', [CompletionResultType]::ParameterName, 'How to display date [possible values: date, relative, +date-time-format]')
            [CompletionResult]::new('--sort', 'sort', [CompletionResultType]::ParameterName, 'sort by WORD instead of name')
            [CompletionResult]::new('--group-dirs', 'group-dirs', [CompletionResultType]::ParameterName, 'Sort the directories then the files')
            [CompletionResult]::new('--blocks', 'blocks', [CompletionResultType]::ParameterName, 'Specify the blocks that will be displayed and in what order')
            [CompletionResult]::new('-I', 'I', [CompletionResultType]::ParameterName, 'Do not display files/directories with names matching the glob pattern(s). More than one can be specified by repeating the argument')
            [CompletionResult]::new('--ignore-glob', 'ignore-glob', [CompletionResultType]::ParameterName, 'Do not display files/directories with names matching the glob pattern(s). More than one can be specified by repeating the argument')
            [CompletionResult]::new('-a', 'a', [CompletionResultType]::ParameterName, 'Do not ignore entries starting with .')
            [CompletionResult]::new('--all', 'all', [CompletionResultType]::ParameterName, 'Do not ignore entries starting with .')
            [CompletionResult]::new('-A', 'A', [CompletionResultType]::ParameterName, 'Do not list implied . and ..')
            [CompletionResult]::new('--almost-all', 'almost-all', [CompletionResultType]::ParameterName, 'Do not list implied . and ..')
            [CompletionResult]::new('-F', 'F', [CompletionResultType]::ParameterName, 'Append indicator (one of */=>@|) at the end of the file names')
            [CompletionResult]::new('--classify', 'classify', [CompletionResultType]::ParameterName, 'Append indicator (one of */=>@|) at the end of the file names')
            [CompletionResult]::new('-l', 'l', [CompletionResultType]::ParameterName, 'Display extended file metadata as a table')
            [CompletionResult]::new('--long', 'long', [CompletionResultType]::ParameterName, 'Display extended file metadata as a table')
            [CompletionResult]::new('--ignore-config', 'ignore-config', [CompletionResultType]::ParameterName, 'Ignore the configuration file')
            [CompletionResult]::new('-1', '1', [CompletionResultType]::ParameterName, 'Display one entry per line')
            [CompletionResult]::new('--oneline', 'oneline', [CompletionResultType]::ParameterName, 'Display one entry per line')
            [CompletionResult]::new('-R', 'R', [CompletionResultType]::ParameterName, 'Recurse into directories')
            [CompletionResult]::new('--recursive', 'recursive', [CompletionResultType]::ParameterName, 'Recurse into directories')
            [CompletionResult]::new('-h', 'h', [CompletionResultType]::ParameterName, 'For ls compatibility purposes ONLY, currently set by default')
            [CompletionResult]::new('--human-readable', 'human-readable', [CompletionResultType]::ParameterName, 'For ls compatibility purposes ONLY, currently set by default')
            [CompletionResult]::new('--tree', 'tree', [CompletionResultType]::ParameterName, 'Recurse into directories and present the result as a tree')
            [CompletionResult]::new('-d', 'd', [CompletionResultType]::ParameterName, 'Display directories themselves, and not their contents')
            [CompletionResult]::new('--directory-only', 'directory-only', [CompletionResultType]::ParameterName, 'Display directories themselves, and not their contents')
            [CompletionResult]::new('--total-size', 'total-size', [CompletionResultType]::ParameterName, 'Display the total size of directories')
            [CompletionResult]::new('-t', 't', [CompletionResultType]::ParameterName, 'Sort by time modified')
            [CompletionResult]::new('--timesort', 'timesort', [CompletionResultType]::ParameterName, 'Sort by time modified')
            [CompletionResult]::new('-S', 'S', [CompletionResultType]::ParameterName, 'Sort by size')
            [CompletionResult]::new('--sizesort', 'sizesort', [CompletionResultType]::ParameterName, 'Sort by size')
            [CompletionResult]::new('-X', 'X', [CompletionResultType]::ParameterName, 'Sort by file extension')
            [CompletionResult]::new('--extensionsort', 'extensionsort', [CompletionResultType]::ParameterName, 'Sort by file extension')
            [CompletionResult]::new('-v', 'v', [CompletionResultType]::ParameterName, 'Natural sort of (version) numbers within text')
            [CompletionResult]::new('--versionsort', 'versionsort', [CompletionResultType]::ParameterName, 'Natural sort of (version) numbers within text')
            [CompletionResult]::new('-r', 'r', [CompletionResultType]::ParameterName, 'Reverse the order of the sort')
            [CompletionResult]::new('--reverse', 'reverse', [CompletionResultType]::ParameterName, 'Reverse the order of the sort')
            [CompletionResult]::new('--classic', 'classic', [CompletionResultType]::ParameterName, 'Enable classic mode (no colors or icons)')
            [CompletionResult]::new('--no-symlink', 'no-symlink', [CompletionResultType]::ParameterName, 'Do not display symlink target')
            [CompletionResult]::new('-i', 'i', [CompletionResultType]::ParameterName, 'Display the index number of each file')
            [CompletionResult]::new('--inode', 'inode', [CompletionResultType]::ParameterName, 'Display the index number of each file')
            [CompletionResult]::new('-L', 'L', [CompletionResultType]::ParameterName, 'When showing file information for a symbolic link, show information for the file the link references rather than for the link itself')
            [CompletionResult]::new('--dereference', 'dereference', [CompletionResultType]::ParameterName, 'When showing file information for a symbolic link, show information for the file the link references rather than for the link itself')
            [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information')
            [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
            [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}
