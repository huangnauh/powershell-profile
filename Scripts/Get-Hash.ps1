function Get-Hash {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="String", Position = 0)]
        [AllowEmptyString()]
        [System.String[]]
        $String,

        [ValidateSet("SHA1", "SHA256", "SHA384", "SHA512", "MACTripleDES", "MD5", "RIPEMD160")]
        [System.String]
        $Algorithm="SHA256"
    )
    
    begin
    {
        # Construct the strongly-typed crypto object
        
        # First see if it has a FIPS algorithm  
        $hasherType = "System.Security.Cryptography.${Algorithm}CryptoServiceProvider" -as [Type]
        if ($hasherType)
        {
            $hasher = $hasherType::New()
        }
        else
        {
            # Check if the type is supported in the current system
            $algorithmType = "System.Security.Cryptography.${Algorithm}" -as [Type]
            if ($algorithmType)
            {
                if ($Algorithm -eq "MACTripleDES")
                {
                    $hasher = $algorithmType::New()
                }
                else
                {
                    $hasher = $algorithmType::Create()
                }
            }
            else
            {
                $errorId = "AlgorithmTypeNotSupported"
                $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
                $errorMessage = [Microsoft.PowerShell.Commands.UtilityResources]::AlgorithmTypeNotSupported -f $Algorithm
                $exception = [System.InvalidOperationException]::New($errorMessage)
                $errorRecord = [System.Management.Automation.ErrorRecord]::New($exception, $errorId, $errorCategory, $null)
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
    }

    process
    {
        $obj = New-Object System.Text.UTF8Encoding
        [Byte[]] $computedHash = $Hasher.ComputeHash($obj.GetBytes($String))
        [string] $hash = [BitConverter]::ToString($computedHash) -replace '-',''
        $hash
    }
}