function ConvertFrom-Base64 {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="InputObject", Position = 0)]
        [AllowEmptyString()]
        [System.String[]]
        $InputObject,

        [ValidateSet("UNICODE", "ASCII")]
        [System.String]
        $Encode="ASCII"
    )
    process
    {
        $InputObject | ForEach-Object {
            if( $_ -eq $null )
            {
                return $null
            }

            $Encoding = ([Text.Encoding]::$Encode)
            $bytes = [Convert]::FromBase64String($_)
            $Encoding.GetString($bytes)
        }
    }
}