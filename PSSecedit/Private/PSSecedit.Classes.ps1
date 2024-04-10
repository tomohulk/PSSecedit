Enum SeceditUserRights {
    SeNetworkLogonRight
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
        $this.Value = $this.GetValue()
    }

    [System.IO.FileInfo]ExportSdb() {
        $path = "${env:Temp}\PSSecedit\PSSecedit_$($this.Area).inf"
        Start-Process -FilePath secedit.exe -ArgumentList "/export /cfg $path /areas $($this.Area) /quiet" -Wait
        return (Get-Item -Path $path)
    }

    [Void]ImportSdb() {
        $path = "${env:Temp}\PSSecedit\PSSecedit_$($this.Area).inf"
        $content = Get-Content -Path $path
        $formatedContent = $content[0..5]
        $formatedContent += $content[6..($content.Length)].Replace("=", " = ")
        Set-Content -Path $path -Value $formatedContent -Force
        Start-Process -FilePath secedit.exe -ArgumentList "/configure /db hisecws.sdb /overwrite /cfg $path /areas $($this.Area) /quiet" -Wait
    }

    [System.String[]]GetValue() {
        $content = Get-IniContent -FilePath $this.ExportSdb()
        return ($content["Privilege Rights"]["$($this.Name)"] -split ",")
    }

    [SeceditObject]SetValue([System.String[]]$PropertyValue) {
        $content = Get-IniContent -FilePath $this.ExportSdb()
        if ($PropertyValue.Count -gt 1) {
            $PropertyValue = $PropertyValue -join ","
        }
        $content["Privilege Rights"]["$($this.Name)"] = $PropertyValue
        Out-IniFile -FilePath "${env:Temp}\PSSecedit\PSSecedit_$($this.Area).inf" -InputObject $content -Force
        cp "${env:Temp}\PSSecedit\PSSecedit_$($this.Area).inf" "${env:Temp}\PSSecedit\PSSecedit_$($this.Area)_modded.inf"
        $this.ImportSdb()
        return ([SeceditObject]::new($this.Name, $this.Area))
    }
}
