#region LoadFunctions

foreach ($value in (((Get-IniContent -FilePath ([PSSeceditObject]::new([PSSeceditArea]"USER_RIGHTS")).ExportSdb()))['Privilege Rights']).Keys) {
    Set-Content "Function:Get-$value" -Value '[PSSeceditObject]::new($MyInvocation.MyCommand.Noun, "USER_RIGHTS")'
    Set-Content "Function:Set-$value" -Value 'param ([String[]]$Value) ([PSSeceditObject]::new($MyInvocation.MyCommand.Noun, "USER_RIGHTS")).SetValue($Value)'
    Export-ModuleMember -Function "Get-$value", "Set-$value"
}

#endregion LoadFunctions
