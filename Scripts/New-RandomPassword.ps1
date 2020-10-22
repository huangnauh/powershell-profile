function New-RandomPassword {
    param(
        [Parameter(ParameterSetName="Length", Position = 0)]
        [int]$Length=8,

        [Parameter()]
        [switch]$IncludeSpecialCharacters = $false,

        [Parameter()]
        [string]$CustomInputString
    )

    BEGIN
	{
		$chars = "ABCDEFGHIJKLMNOPQRSTUVWabcdefghijklmnopqrstuvwxyz1234567890"
        $specials = "!@#$%^&*(){}[]<>?"

        if($IncludeSpecialCharacters) {
            $chars = $chars + $specials
        }

        if($CustomInputString) {
            $chars = $null
            $chars = $chars + $CustomInputString
        }
    }
    
    PROCESS
    {
        for ($i=1; $i –le $Length; $i++) {
            $n = Get-Random -Maximum ($chars.length)
            $password += $chars[$n]
        }
        $password
    }
}