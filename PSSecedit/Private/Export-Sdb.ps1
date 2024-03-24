Function Export-Sdb {
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]

    param (
        [Parameter()]
        [String]
        $Configuration = (Join-Path -Path (Join-Path -Path $env:TEMP -ChildPath "PSSecedit") -ChildPath "PSSecedit_SDB.inf"),

        [Parameter(Mandatory)]
        [ValidateSet("FILESTORE", "GROUP_MGMT", "REGKEYS", "SECURITYPOLICY", "SERVICES", "USER_RIGHTS")]
        [String[]]
        $Area,

        [Parameter()]
        [String]
        $Log
    )

    begin {
        if (Test-Path -Path $Configuration) {
            Remove-Item -Path (Split-Path -Path $Configuration -Parent) -Recurse -Force -Confirm:$false
        }

        New-Item -Path (Split-Path -Path $Configuration -Parent) -ItemType Directory | Out-Null
    }

    process {
        Start-Process -FilePath secedit.exe -ArgumentList "/export /cfg ${Configuration} /areas ${Area} /quiet" -Wait
    }

    end {
        return (Get-Item -Path $Configuration)
    }
}
