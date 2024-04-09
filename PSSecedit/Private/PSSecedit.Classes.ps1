Enum SeceditUserRights {
    SeNetworkLogonRight
    SeBackupPrivilege
    SeChangeNotifyPrivilege
    SeSystemtimePrivilege
    SeCreatePagefilePrivilege
}

Enum SeceditArea {
    FILESTORE
    GROUP_MGMT
    REGKEYS
    SECURITYPOLICY
    SERVICES
    USER_RIGHTS
}

Class SeceditObject {
    [System.String]$Name
    [System.String[]]$Value
    [Nullable[SeceditArea]]$Area

    SeceditObject([System.String]$Name, [SeceditArea]$Area) {
        $this.Name = $Name
        $this.Area = $Area
        $this.Value = $this.GetValue($Name, $Area)
    }

    [System.IO.FileInfo]ExportSdb([SeceditArea]$Area) {
        $path = "${env:Temp}\PSSecedit\PSSecedit_${Area}.inf"
        Start-Process -FilePath secedit.exe -ArgumentList "/export /cfg $path /areas ${Area} /quiet" -Wait
        return (Get-Item -Path $path)
    }

    [System.String[]]GetValue([System.String]$Property, [SeceditArea]$Area) {
        $content = Get-Content -Path $this.ExportSdb($Area)
        return ((($content | Select-String $Property).Line.Split("=").Trim() | Select-Object -Last 1) -split "," | %{ $_.Trim()})
    }
}
