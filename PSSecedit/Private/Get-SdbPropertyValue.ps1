Function Get-SdbPropertyValue {
    [CmdletBinding()]
    [OutputType()]

    param(
        [Parameter()]
        [System.IO.FileInfo]
        $SdbIni = (Export-Sdb -Area USER_RIGHTS),

        [Parameter(Mandatory)]
        [String[]]
        $Property
    )

    begin {
        $content = Get-Content -Path $SdbIni
    }

    process {
        ($content | Select-String $Property).Line.Split("=").Trim() | Select-Object -Last 1
    }
}
